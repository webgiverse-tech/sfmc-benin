const axios = require('axios');

const PRODUCT_URL = process.env.PRODUCT_SERVICE_URL || 'http://localhost:3003';

async function getProductDetails(productId) {
    try {
        const response = await axios.get(`${PRODUCT_URL}/products/${productId}`);
        return response.data.data;
    } catch (error) {
        console.error('Erreur récupération produit:', error.message);
        throw new Error('Service produit indisponible');
    }
}

module.exports = { getProductDetails };