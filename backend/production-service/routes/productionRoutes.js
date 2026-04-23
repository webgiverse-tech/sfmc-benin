const express = require('express');
const router = express.Router();
const controller = require('../controllers/productionController');

router.get('/', controller.getAllProductionOrders);
router.get('/machines', controller.getMachines);
router.post('/machines', controller.createMachine);
router.get('/:id', controller.getProductionOrderById);
router.post('/', controller.createProductionOrder);
router.put('/:id/status', controller.updateProductionStatus);

module.exports = router;