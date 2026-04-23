const { runAsync, getAsync, allAsync } = require('../database/db');
const { addToInventory } = require('../services/inventoryClient');

// GET /production – liste des ordres de production
exports.getAllProductionOrders = async (req, res, next) => {
    try {
        const { statut, machine_id } = req.query;
        let query = `
      SELECT po.*, m.nom as machine_nom, p.nom as product_name
      FROM production_orders po
      LEFT JOIN machines m ON po.machine_id = m.id
      LEFT JOIN products p ON po.product_id = p.id
      WHERE 1=1
    `;
        const params = [];

        if (statut) { query += ' AND po.statut = ?'; params.push(statut); }
        if (machine_id) { query += ' AND po.machine_id = ?'; params.push(machine_id); }

        query += ' ORDER BY po.date_debut DESC';

        const orders = await allAsync(query, params);
        res.json({ success: true, count: orders.length, data: orders });
    } catch (error) {
        next(error);
    }
};

// GET /production/:id – détail d'un ordre
exports.getProductionOrderById = async (req, res, next) => {
    try {
        const order = await getAsync(`
      SELECT po.*, m.nom as machine_nom, p.nom as product_name
      FROM production_orders po
      LEFT JOIN machines m ON po.machine_id = m.id
      LEFT JOIN products p ON po.product_id = p.id
      WHERE po.id = ?
    `, [req.params.id]);

        if (!order) return res.status(404).json({ success: false, error: 'Ordre de production non trouvé' });
        res.json({ success: true, data: order });
    } catch (error) {
        next(error);
    }
};

// POST /production – créer un nouvel ordre
exports.createProductionOrder = async (req, res, next) => {
    try {
        const { product_id, quantity_target, date_debut, machine_id, notes } = req.body;
        if (!product_id || !quantity_target) {
            return res.status(400).json({ success: false, error: 'product_id et quantity_target requis' });
        }

        // Vérifier que la machine existe et est disponible (si fournie)
        if (machine_id) {
            const machine = await getAsync(`SELECT statut FROM machines WHERE id = ?`, [machine_id]);
            if (!machine) return res.status(400).json({ success: false, error: 'Machine inexistante' });
            if (machine.statut !== 'available') {
                return res.status(400).json({ success: false, error: 'Machine non disponible' });
            }
        }

        const result = await runAsync(
            `INSERT INTO production_orders (product_id, quantity_target, date_debut, machine_id, notes) VALUES (?, ?, ?, ?, ?)`,
            [product_id, quantity_target, date_debut || null, machine_id || null, notes || null]
        );

        const newOrder = await getAsync(`
      SELECT po.*, m.nom as machine_nom, p.nom as product_name
      FROM production_orders po
      LEFT JOIN machines m ON po.machine_id = m.id
      LEFT JOIN products p ON po.product_id = p.id
      WHERE po.id = ?
    `, [result.lastID]);

        res.status(201).json({ success: true, message: 'Ordre de production créé', data: newOrder });
    } catch (error) {
        next(error);
    }
};

// PUT /production/:id/status – changer le statut (et gérer la fin de production)
exports.updateProductionStatus = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { statut, quantity_produced, date_fin } = req.body;

        const validStatuses = ['planned', 'in_progress', 'completed', 'cancelled'];
        if (!validStatuses.includes(statut)) {
            return res.status(400).json({ success: false, error: 'Statut invalide' });
        }

        const order = await getAsync(`SELECT * FROM production_orders WHERE id = ?`, [id]);
        if (!order) return res.status(404).json({ success: false, error: 'Ordre non trouvé' });

        // Construire les champs à mettre à jour
        const updates = { statut };
        if (quantity_produced !== undefined) updates.quantity_produced = quantity_produced;
        if (date_fin) updates.date_fin = date_fin;
        if (statut === 'completed' && !updates.date_fin) updates.date_fin = new Date().toISOString().split('T')[0];

        let sql = 'UPDATE production_orders SET ';
        const params = [];
        const fields = [];
        for (const [key, value] of Object.entries(updates)) {
            fields.push(`${key} = ?`);
            params.push(value);
        }
        sql += fields.join(', ') + ' WHERE id = ?';
        params.push(id);

        await runAsync(sql, params);

        // Si le statut passe à 'completed', ajouter la quantité produite au stock
        if (statut === 'completed' && order.statut !== 'completed') {
            try {
                const producedQty = quantity_produced !== undefined ? quantity_produced : order.quantity_target;
                await addToInventory(order.product_id, producedQty, `Production order #${id} completed`);
                console.log(`✅ Stock mis à jour pour le produit ${order.product_id} (+${producedQty})`);
            } catch (err) {
                console.error('⚠️ Échec de la mise à jour du stock:', err.message);
                // On continue quand même
            }
        }

        const updated = await getAsync(`
      SELECT po.*, m.nom as machine_nom, p.nom as product_name
      FROM production_orders po
      LEFT JOIN machines m ON po.machine_id = m.id
      LEFT JOIN products p ON po.product_id = p.id
      WHERE po.id = ?
    `, [id]);

        res.json({ success: true, message: 'Statut mis à jour', data: updated });
    } catch (error) {
        next(error);
    }
};

// GET /production/machines – état des machines
exports.getMachines = async (req, res, next) => {
    try {
        const machines = await allAsync(`SELECT * FROM machines ORDER BY nom`);
        res.json({ success: true, count: machines.length, data: machines });
    } catch (error) {
        next(error);
    }
};

// POST /production/machines – ajouter une machine
exports.createMachine = async (req, res, next) => {
    try {
        const { nom, capacite_jour, statut = 'available' } = req.body;
        if (!nom) return res.status(400).json({ success: false, error: 'Nom requis' });

        const result = await runAsync(
            `INSERT INTO machines (nom, capacite_jour, statut) VALUES (?, ?, ?)`,
            [nom, capacite_jour || 0, statut]
        );
        const machine = await getAsync(`SELECT * FROM machines WHERE id = ?`, [result.lastID]);
        res.status(201).json({ success: true, data: machine });
    } catch (error) {
        next(error);
    }
};