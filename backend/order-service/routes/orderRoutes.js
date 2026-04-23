const express = require('express');
const router = express.Router();
const controller = require('../controllers/orderController');

router.get('/', controller.getAllOrders);
router.get('/:id', controller.getOrderById);
router.post('/', controller.createOrder);
router.put('/:id/status', controller.updateOrderStatus);
router.get('/client/:client_id', controller.getOrdersByClient);

module.exports = router;