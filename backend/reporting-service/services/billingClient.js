const axios = require('axios');
const BILLING_URL = process.env.BILLING_SERVICE_URL || 'http://localhost:3007';

async function getAllFactures() {
    const response = await axios.get(`${BILLING_URL}/billing/factures`);
    return response.data.data;
}

async function getStats() {
    const response = await axios.get(`${BILLING_URL}/billing/stats`);
    return response.data.data;
}

module.exports = { getAllFactures, getStats };