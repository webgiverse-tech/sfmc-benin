const axios = require('axios');

const ORDER_URL = process.env.ORDER_SERVICE_URL || 'http://localhost:3005';

async function getOrderById(orderId) {
    try {
        const response = await axios.get(`${ORDER_URL}/orders/${orderId}`);
        return response.data.data;
    } catch (error) {
        console.error('Erreur récupération commande:', error.message);
        throw new Error('Commande introuvable ou service indisponible');
    }
}

module.exports = { getOrderById };