const { runAsync, getAsync, allAsync } = require('../database/db');

// État complet des stocks avec jointure sur les entrepôts
exports.getFullInventory = async (req, res, next) => {
    try {
        const rows = await allAsync(`
      SELECT s.id, s.product_id, p.nom as product_name, s.warehouse_id, w.nom as warehouse_name,
             s.quantity, s.seuil_critique, s.updated_at
      FROM stock s
      LEFT JOIN warehouses w ON s.warehouse_id = w.id
      LEFT JOIN products p ON s.product_id = p.id
      ORDER BY w.nom, p.nom
    `);
        res.json({ success: true, count: rows.length, data: rows });
    } catch (error) {
        next(error);
    }
};

// Stock d'un produit spécifique
exports.getStockByProduct = async (req, res, next) => {
    try {
        const { product_id } = req.params;
        const rows = await allAsync(`
      SELECT s.*, w.nom as warehouse_name
      FROM stock s
      LEFT JOIN warehouses w ON s.warehouse_id = w.id
      WHERE s.product_id = ?
    `, [product_id]);
        res.json({ success: true, data: rows });
    } catch (error) {
        next(error);
    }
};

// Ajouter un mouvement de stock
exports.addMovement = async (req, res, next) => {
    try {
        const { product_id, warehouse_id, type, quantity, reason, user_id } = req.body;
        if (!product_id || !warehouse_id || !type || !quantity) {
            return res.status(400).json({ success: false, error: 'Champs obligatoires manquants' });
        }
        if (!['IN', 'OUT'].includes(type)) {
            return res.status(400).json({ success: false, error: 'Type doit être IN ou OUT' });
        }

        const result = await runAsync(
            `INSERT INTO stock_movements (product_id, warehouse_id, type, quantity, reason, user_id) VALUES (?, ?, ?, ?, ?, ?)`,
            [product_id, warehouse_id, type, quantity, reason || null, user_id || null]
        );
        const movement = await getAsync('SELECT * FROM stock_movements WHERE id = ?', [result.lastID]);
        res.status(201).json({ success: true, message: 'Mouvement enregistré', data: movement });
    } catch (error) {
        next(error);
    }
};

// Historique des mouvements avec filtres
exports.getMovements = async (req, res, next) => {
    try {
        const { product_id, warehouse_id, type, start_date, end_date } = req.query;
        let query = `SELECT m.*, p.nom as product_name, w.nom as warehouse_name 
                 FROM stock_movements m
                 LEFT JOIN products p ON m.product_id = p.id
                 LEFT JOIN warehouses w ON m.warehouse_id = w.id WHERE 1=1`;
        const params = [];

        if (product_id) { query += ' AND m.product_id = ?'; params.push(product_id); }
        if (warehouse_id) { query += ' AND m.warehouse_id = ?'; params.push(warehouse_id); }
        if (type) { query += ' AND m.type = ?'; params.push(type); }
        if (start_date) { query += ' AND m.date >= ?'; params.push(start_date); }
        if (end_date) { query += ' AND m.date <= ?'; params.push(end_date + ' 23:59:59'); }

        query += ' ORDER BY m.date DESC LIMIT 100';
        const movements = await allAsync(query, params);
        res.json({ success: true, count: movements.length, data: movements });
    } catch (error) {
        next(error);
    }
};

// Alertes : produits sous seuil critique
exports.getAlerts = async (req, res, next) => {
    try {
        const alerts = await allAsync(`
      SELECT s.*, p.nom as product_name, w.nom as warehouse_name
      FROM stock s
      LEFT JOIN products p ON s.product_id = p.id
      LEFT JOIN warehouses w ON s.warehouse_id = w.id
      WHERE s.quantity <= s.seuil_critique AND s.seuil_critique > 0
    `);
        res.json({ success: true, count: alerts.length, data: alerts });
    } catch (error) {
        next(error);
    }
};