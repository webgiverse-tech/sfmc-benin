// inventory-service/routes/inventoryRoutes.js — Corrigé
const express = require('express');
const router = express.Router();
const controller = require('../controllers/inventoryController');

router.get('/', controller.getFullInventory);
router.get('/alerts', controller.getAlerts);
router.get('/movements', controller.getMovements);
router.get('/warehouses', controller.getWarehouses);
router.get('/product/:product_id', controller.getStockByProduct);
router.post('/movement', controller.addMovement);

module.exports = router;
