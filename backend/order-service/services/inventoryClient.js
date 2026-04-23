const axios = require('axios');

const INVENTORY_URL = process.env.INVENTORY_SERVICE_URL || 'http://localhost:3004';

async function checkStockAvailability(productId, quantity) {
    try {
        const response = await axios.get(`${INVENTORY_URL}/inventory/product/${productId}`);
        const stocks = response.data.data || [];
        const totalAvailable = stocks.reduce((sum, s) => sum + s.quantity, 0);
        return { available: totalAvailable >= quantity, total: totalAvailable, details: stocks };
    } catch (error) {
        console.error('Erreur vérification stock:', error.message);
        throw new Error('Service inventaire indisponible');
    }
}

async function reserveStock(orderId, items) {
    // Dans une version réelle, on pourrait enregistrer des mouvements de sortie provisoires
    // Pour l'instant, on ne fait qu'enregistrer la commande, le stock sera mis à jour lors de la validation
    return true;
}

module.exports = { checkStockAvailability, reserveStock };