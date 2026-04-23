const axios = require('axios');
const ORDER_URL = process.env.ORDER_SERVICE_URL || 'http://localhost:3005';

async function getAllOrders(filters = {}) {
    const params = new URLSearchParams(filters).toString();
    const response = await axios.get(`${ORDER_URL}/orders?${params}`);
    return response.data.data;
}

module.exports = { getAllOrders };