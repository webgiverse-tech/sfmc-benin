// inventory-service/controllers/inventoryController.js — Corrigé
const { runAsync, getAsync, allAsync } = require('../database/db');

// GET /inventory — État complet des stocks
exports.getFullInventory = async (req, res, next) => {
    try {
        const rows = await allAsync(`
            SELECT 
                s.id, s.product_id,
                COALESCE(p.nom, 'Produit #' || s.product_id) as product_name,
                s.warehouse_id,
                COALESCE(w.nom, 'Entrepôt #' || s.warehouse_id) as warehouse_name,
                s.quantity, s.seuil_critique, s.updated_at
            FROM stock s
            LEFT JOIN warehouses w ON s.warehouse_id = w.id
            LEFT JOIN products p ON s.product_id = p.id
            ORDER BY w.nom, product_name
        `);
        res.json({ success: true, count: rows.length, data: rows });
    } catch (error) {
        next(error);
    }
};

// GET /inventory/product/:product_id — Stock d'un produit par entrepôt
exports.getStockByProduct = async (req, res, next) => {
    try {
        const { product_id } = req.params;
        const rows = await allAsync(`
            SELECT s.*, COALESCE(w.nom, 'Entrepôt #' || s.warehouse_id) as warehouse_name
            FROM stock s
            LEFT JOIN warehouses w ON s.warehouse_id = w.id
            WHERE s.product_id = ?
        `, [product_id]);
        res.json({ success: true, data: rows });
    } catch (error) {
        next(error);
    }
};

// POST /inventory/movement — Ajouter un mouvement de stock
exports.addMovement = async (req, res, next) => {
    try {
        const { product_id, warehouse_id, type, quantity, reason, user_id } = req.body;

        if (!product_id || !warehouse_id || !type || !quantity) {
            return res.status(400).json({ success: false, error: 'product_id, warehouse_id, type et quantity sont requis' });
        }
        if (!['IN', 'OUT'].includes(type.toUpperCase())) {
            return res.status(400).json({ success: false, error: 'Le type doit être IN ou OUT' });
        }
        if (quantity <= 0) {
            return res.status(400).json({ success: false, error: 'La quantité doit être positive' });
        }

        // Vérifier le stock disponible pour une sortie
        if (type.toUpperCase() === 'OUT') {
            const currentStock = await getAsync(
                'SELECT quantity FROM stock WHERE product_id = ? AND warehouse_id = ?',
                [product_id, warehouse_id]
            );
            if (!currentStock || currentStock.quantity < quantity) {
                const available = currentStock ? currentStock.quantity : 0;
                return res.status(400).json({
                    success: false,
                    error: `Stock insuffisant. Disponible: ${available}, Demandé: ${quantity}`
                });
            }
        }

        const result = await runAsync(
            `INSERT INTO stock_movements (product_id, warehouse_id, type, quantity, reason, user_id) 
             VALUES (?, ?, ?, ?, ?, ?)`,
            [product_id, warehouse_id, type.toUpperCase(), quantity, reason || null, user_id || null]
        );

        const movement = await getAsync('SELECT * FROM stock_movements WHERE id = ?', [result.lastID]);
        const updatedStock = await getAsync(
            'SELECT quantity FROM stock WHERE product_id = ? AND warehouse_id = ?',
            [product_id, warehouse_id]
        );

        res.status(201).json({
            success: true,
            message: 'Mouvement enregistré',
            data: movement,
            stock_after: updatedStock ? updatedStock.quantity : null
        });
    } catch (error) {
        next(error);
    }
};

// GET /inventory/movements — Historique des mouvements
exports.getMovements = async (req, res, next) => {
    try {
        const { product_id, warehouse_id, type, start_date, end_date, limit = 100 } = req.query;
        let query = `
            SELECT 
                m.*,
                COALESCE(p.nom, 'Produit #' || m.product_id) as product_name,
                COALESCE(w.nom, 'Entrepôt #' || m.warehouse_id) as warehouse_name
            FROM stock_movements m
            LEFT JOIN products p ON m.product_id = p.id
            LEFT JOIN warehouses w ON m.warehouse_id = w.id
            WHERE 1=1
        `;
        const params = [];

        if (product_id) { query += ' AND m.product_id = ?'; params.push(product_id); }
        if (warehouse_id) { query += ' AND m.warehouse_id = ?'; params.push(warehouse_id); }
        if (type) { query += ' AND m.type = ?'; params.push(type.toUpperCase()); }
        if (start_date) { query += ' AND m.date >= ?'; params.push(start_date); }
        if (end_date) { query += ' AND m.date <= ?'; params.push(end_date + ' 23:59:59'); }

        query += ` ORDER BY m.date DESC LIMIT ?`;
        params.push(parseInt(limit));

        const movements = await allAsync(query, params);
        res.json({ success: true, count: movements.length, data: movements });
    } catch (error) {
        next(error);
    }
};

// GET /inventory/alerts — Produits sous seuil critique
exports.getAlerts = async (req, res, next) => {
    try {
        const alerts = await allAsync(`
            SELECT 
                s.*,
                COALESCE(p.nom, 'Produit #' || s.product_id) as product_name,
                COALESCE(w.nom, 'Entrepôt #' || s.warehouse_id) as warehouse_name
            FROM stock s
            LEFT JOIN products p ON s.product_id = p.id
            LEFT JOIN warehouses w ON s.warehouse_id = w.id
            WHERE s.quantity <= s.seuil_critique AND s.seuil_critique > 0
            ORDER BY (s.seuil_critique - s.quantity) DESC
        `);
        res.json({ success: true, count: alerts.length, data: alerts });
    } catch (error) {
        next(error);
    }
};

// GET /inventory/warehouses — Liste des entrepôts
exports.getWarehouses = async (req, res, next) => {
    try {
        const warehouses = await allAsync('SELECT * FROM warehouses ORDER BY nom');
        res.json({ success: true, count: warehouses.length, data: warehouses });
    } catch (error) {
        next(error);
    }
};
