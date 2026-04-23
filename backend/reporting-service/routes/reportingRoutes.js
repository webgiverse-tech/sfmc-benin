const express = require('express');
const router = express.Router();
const controller = require('../controllers/reportingController');

router.get('/dashboard', controller.getDashboard);
router.get('/ventes', controller.getSalesReport);
router.get('/stock', controller.getStockReport);
router.get('/production', controller.getProductionReport);
router.get('/finances', controller.getFinanceReport);

module.exports = router;