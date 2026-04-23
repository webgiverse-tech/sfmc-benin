const { runAsync, getAsync, allAsync } = require('../database/db');
const { checkStockAvailability } = require('../services/inventoryClient');
const { getProductDetails } = require('../services/productClient');

// GET /orders
exports.getAllOrders = async (req, res, next) => {
    try {
        const { statut, client_id } = req.query;
        let query = 'SELECT * FROM orders WHERE 1=1';
        const params = [];

        if (statut) { query += ' AND statut = ?'; params.push(statut); }
        if (client_id) { query += ' AND client_id = ?'; params.push(client_id); }

        query += ' ORDER BY date_commande DESC';
        const orders = await allAsync(query, params);

        // Récupérer les items pour chaque commande
        for (let order of orders) {
            order.items = await allAsync('SELECT * FROM order_items WHERE order_id = ?', [order.id]);
        }

        res.json({ success: true, count: orders.length, data: orders });
    } catch (error) {
        next(error);
    }
};

// GET /orders/:id
exports.getOrderById = async (req, res, next) => {
    try {
        const order = await getAsync('SELECT * FROM orders WHERE id = ?', [req.params.id]);
        if (!order) return res.status(404).json({ success: false, error: 'Commande non trouvée' });
        order.items = await allAsync('SELECT * FROM order_items WHERE order_id = ?', [order.id]);
        res.json({ success: true, data: order });
    } catch (error) {
        next(error);
    }
};

// POST /orders
exports.createOrder = async (req, res, next) => {
    try {
        const { client_id, date_livraison_prevue, items, notes } = req.body;
        if (!client_id || !items || !Array.isArray(items) || items.length === 0) {
            return res.status(400).json({ success: false, error: 'client_id et items (non vide) requis' });
        }

        // Vérifier les stocks et récupérer les prix
        for (const item of items) {
            const stockCheck = await checkStockAvailability(item.product_id, item.quantity);
            if (!stockCheck.available) {
                return res.status(400).json({
                    success: false,
                    error: `Stock insuffisant pour le produit ${item.product_id}. Disponible: ${stockCheck.total}`
                });
            }
            // Récupérer le prix unitaire depuis le Product Service
            try {
                const product = await getProductDetails(item.product_id);
                item.prix_unitaire = product.prix_unitaire;
            } catch (e) {
                return res.status(400).json({ success: false, error: `Produit ${item.product_id} introuvable` });
            }
        }

        // Créer la commande
        const result = await runAsync(
            `INSERT INTO orders (client_id, date_livraison_prevue, notes) VALUES (?, ?, ?)`,
            [client_id, date_livraison_prevue || null, notes || null]
        );
        const orderId = result.lastID;

        // Insérer les items
        for (const item of items) {
            await runAsync(
                `INSERT INTO order_items (order_id, product_id, quantity, prix_unitaire) VALUES (?, ?, ?, ?)`,
                [orderId, item.product_id, item.quantity, item.prix_unitaire]
            );
        }

        // Récupérer la commande créée
        const newOrder = await getAsync('SELECT * FROM orders WHERE id = ?', [orderId]);
        newOrder.items = await allAsync('SELECT * FROM order_items WHERE order_id = ?', [orderId]);

        // Émettre un événement (à implémenter plus tard) : OrderCreated
        // eventEmitter.emit('OrderCreated', newOrder);

        res.status(201).json({ success: true, message: 'Commande créée', data: newOrder });
    } catch (error) {
        next(error);
    }
};

// PUT /orders/:id/status
exports.updateOrderStatus = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { statut } = req.body;
        const validStatuses = ['pending', 'validated', 'shipped', 'delivered', 'cancelled'];
        if (!validStatuses.includes(statut)) {
            return res.status(400).json({ success: false, error: 'Statut invalide' });
        }

        const order = await getAsync('SELECT * FROM orders WHERE id = ?', [id]);
        if (!order) return res.status(404).json({ success: false, error: 'Commande non trouvée' });

        // Logique métier : quand on passe à 'validated', on pourrait réserver le stock définitivement
        // Pour l'instant, on change simplement le statut
        await runAsync(`UPDATE orders SET statut = ? WHERE id = ?`, [statut, id]);

        const updated = await getAsync('SELECT * FROM orders WHERE id = ?', [id]);
        updated.items = await allAsync('SELECT * FROM order_items WHERE order_id = ?', [id]);

        // Émettre un événement : OrderStatusChanged
        // eventEmitter.emit('OrderStatusChanged', { orderId: id, newStatus: statut });

        res.json({ success: true, message: 'Statut mis à jour', data: updated });
    } catch (error) {
        next(error);
    }
};

// GET /orders/client/:client_id
exports.getOrdersByClient = async (req, res, next) => {
    try {
        const { client_id } = req.params;
        const orders = await allAsync('SELECT * FROM orders WHERE client_id = ? ORDER BY date_commande DESC', [client_id]);
        for (let order of orders) {
            order.items = await allAsync('SELECT * FROM order_items WHERE order_id = ?', [order.id]);
        }
        res.json({ success: true, count: orders.length, data: orders });
    } catch (error) {
        next(error);
    }
};