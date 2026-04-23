const axios = require('axios');
const PRODUCTION_URL = process.env.PRODUCTION_SERVICE_URL || 'http://localhost:3006';

async function getAllProductionOrders() {
    const response = await axios.get(`${PRODUCTION_URL}/production`);
    return response.data.data;
}

async function getMachines() {
    const response = await axios.get(`${PRODUCTION_URL}/production/machines`);
    return response.data.data;
}

module.exports = { getAllProductionOrders, getMachines };