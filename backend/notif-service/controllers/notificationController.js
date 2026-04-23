const { runAsync, getAsync, allAsync } = require('../database/db');

// GET /notifications/:user_id – toutes les notifications d'un utilisateur
exports.getUserNotifications = async (req, res, next) => {
    try {
        const { user_id } = req.params;
        const { type, read } = req.query;

        let query = 'SELECT * FROM notifications WHERE user_id = ?';
        const params = [user_id];

        if (type) { query += ' AND type = ?'; params.push(type); }
        if (read !== undefined) { query += ' AND read = ?'; params.push(read === 'true' ? 1 : 0); }

        query += ' ORDER BY created_at DESC';

        const notifications = await allAsync(query, params);
        res.json({ success: true, count: notifications.length, data: notifications });
    } catch (error) {
        next(error);
    }
};

// GET /notifications/unread/:user_id – notifications non lues seulement
exports.getUnreadNotifications = async (req, res, next) => {
    try {
        const { user_id } = req.params;
        const notifications = await allAsync(
            'SELECT * FROM notifications WHERE user_id = ? AND read = 0 ORDER BY created_at DESC',
            [user_id]
        );
        res.json({ success: true, count: notifications.length, data: notifications });
    } catch (error) {
        next(error);
    }
};

// POST /notifications – créer une notification
exports.createNotification = async (req, res, next) => {
    try {
        const { user_id, titre, message, type = 'info' } = req.body;
        if (!user_id || !titre || !message) {
            return res.status(400).json({ success: false, error: 'user_id, titre et message requis' });
        }

        const result = await runAsync(
            `INSERT INTO notifications (user_id, titre, message, type) VALUES (?, ?, ?, ?)`,
            [user_id, titre, message, type]
        );

        const notification = await getAsync('SELECT * FROM notifications WHERE id = ?', [result.lastID]);
        res.status(201).json({ success: true, message: 'Notification créée', data: notification });
    } catch (error) {
        next(error);
    }
};

// PUT /notifications/:id/read – marquer comme lue
exports.markAsRead = async (req, res, next) => {
    try {
        const { id } = req.params;
        const existing = await getAsync('SELECT id FROM notifications WHERE id = ?', [id]);
        if (!existing) return res.status(404).json({ success: false, error: 'Notification non trouvée' });

        await runAsync('UPDATE notifications SET read = 1 WHERE id = ?', [id]);
        const updated = await getAsync('SELECT * FROM notifications WHERE id = ?', [id]);
        res.json({ success: true, message: 'Notification marquée comme lue', data: updated });
    } catch (error) {
        next(error);
    }
};

// PUT /notifications/mark-all-read/:user_id – marquer toutes comme lues pour un utilisateur
exports.markAllAsRead = async (req, res, next) => {
    try {
        const { user_id } = req.params;
        await runAsync('UPDATE notifications SET read = 1 WHERE user_id = ? AND read = 0', [user_id]);
        res.json({ success: true, message: 'Toutes les notifications ont été marquées comme lues' });
    } catch (error) {
        next(error);
    }
};