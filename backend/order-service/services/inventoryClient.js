// order-service/services/inventoryClient.js — Corrigé avec meilleure gestion d'erreur
const axios = require('axios');

const INVENTORY_URL = process.env.INVENTORY_SERVICE_URL || 'http://localhost:3004';

/**
 * Vérifie si la quantité demandée est disponible pour un produit.
 * Appel direct entre microservices (bypass Gateway, pas besoin de JWT).
 */
async function checkStockAvailability(productId, quantity) {
    try {
        const response = await axios.get(
            `${INVENTORY_URL}/inventory/product/${productId}`,
            { timeout: 5000 }
        );
        const stocks = response.data.data || [];
        const totalAvailable = stocks.reduce((sum, s) => sum + (s.quantity || 0), 0);
        return {
            available: totalAvailable >= quantity,
            total: totalAvailable,
            details: stocks
        };
    } catch (error) {
        if (error.code === 'ECONNREFUSED') {
            console.error(`❌ Inventory Service inaccessible sur ${INVENTORY_URL}`);
            // En mode dégradé : on autorise la commande si le service est down
            // (comportement configurable selon la politique métier)
            return { available: true, total: -1, degraded: true };
        }
        console.error('❌ Erreur vérification stock:', error.message);
        throw new Error('Erreur lors de la vérification du stock');
    }
}

/**
 * Enregistre un mouvement de sortie de stock lors de la validation d'une commande.
 */
async function decrementStock(productId, warehouseId, quantity, orderId) {
    try {
        await axios.post(
            `${INVENTORY_URL}/inventory/movement`,
            {
                product_id: productId,
                warehouse_id: warehouseId || 1,
                type: 'OUT',
                quantity: quantity,
                reason: `Commande #${orderId}`
            },
            { timeout: 5000 }
        );
        return true;
    } catch (error) {
        console.error(`❌ Erreur décrémentation stock produit ${productId}:`, error.message);
        return false;
    }
}

module.exports = { checkStockAvailability, decrementStock };
