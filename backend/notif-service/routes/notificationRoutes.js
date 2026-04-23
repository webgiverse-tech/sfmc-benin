const express = require('express');
const router = express.Router();
const controller = require('../controllers/notificationController');

router.get('/user/:user_id', controller.getUserNotifications);
router.get('/unread/:user_id', controller.getUnreadNotifications);
router.post('/', controller.createNotification);
router.put('/:id/read', controller.markAsRead);
router.put('/mark-all-read/:user_id', controller.markAllAsRead);

module.exports = router;