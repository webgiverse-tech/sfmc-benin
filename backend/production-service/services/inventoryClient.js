const axios = require('axios');

const INVENTORY_URL = process.env.INVENTORY_SERVICE_URL || 'http://localhost:3004';

/**
 * Met à jour le stock du produit spécifié (ajout de quantité).
 * Appelle l'endpoint POST /inventory/movement pour créer un mouvement d'entrée.
 */
async function addToInventory(productId, quantity, reason = 'Production terminée', userId = null) {
    try {
        // Récupérer l'entrepôt par défaut (ou le premier trouvé)
        const invResponse = await axios.get(`${INVENTORY_URL}/inventory/product/${productId}`);
        const stocks = invResponse.data.data;
        if (!stocks || stocks.length === 0) {
            throw new Error(`Aucun stock trouvé pour le produit ${productId}`);
        }
        const warehouseId = stocks[0].warehouse_id; // On prend le premier entrepôt

        const payload = {
            product_id: productId,
            warehouse_id: warehouseId,
            type: 'IN',
            quantity: quantity,
            reason: reason,
            user_id: userId
        };

        const response = await axios.post(`${INVENTORY_URL}/inventory/movement`, payload);
        return response.data;
    } catch (error) {
        console.error('Erreur mise à jour stock:', error.message);
        throw new Error('Impossible de mettre à jour le stock');
    }
}

module.exports = { addToInventory };