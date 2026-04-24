// notif-service/routes/notifRoutes.js
const express = require('express');
const router = express.Router();

// BUG FIX #3 : Le service DOIT écouter sur /notif/* (cohérent avec le gateway)
// GET /notif/:user_id
router.get('/:user_id', async (req, res) => {
    try {
        const { user_id } = req.params;
        const notifications = db.prepare(
            'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC'
        ).all(user_id);
        res.json({ success: true, data: notifications });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// ... autres routes
module.exports = router;
