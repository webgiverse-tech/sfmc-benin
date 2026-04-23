const axios = require('axios');
const USER_URL = process.env.USER_SERVICE_URL || 'http://localhost:3002';

async function getAllUsers() {
    const response = await axios.get(`${USER_URL}/users`);
    return response.data.data;
}

module.exports = { getAllUsers };