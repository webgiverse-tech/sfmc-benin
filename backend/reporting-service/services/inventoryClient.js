const axios = require('axios');
const INVENTORY_URL = process.env.INVENTORY_SERVICE_URL || 'http://localhost:3004';

async function getFullInventory() {
    const response = await axios.get(`${INVENTORY_URL}/inventory`);
    return response.data.data;
}

async function getAlerts() {
    const response = await axios.get(`${INVENTORY_URL}/inventory/alerts`);
    return response.data.data;
}

module.exports = { getFullInventory, getAlerts };