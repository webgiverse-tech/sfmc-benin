const express = require('express');
const router = express.Router();
const controller = require('../controllers/billingController');

router.get('/factures', controller.getAllFactures);
router.get('/factures/:id', controller.getFactureById);
router.post('/factures', controller.createFactureFromOrder);
router.put('/factures/:id/paiement', controller.addPaiement);
router.get('/stats', controller.getStats);

module.exports = router;