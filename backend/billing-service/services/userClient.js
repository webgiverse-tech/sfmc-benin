const axios = require('axios');

const USER_URL = process.env.USER_SERVICE_URL || 'http://localhost:3002';

async function getUserById(userId) {
    try {
        const response = await axios.get(`${USER_URL}/users/${userId}`);
        return response.data.data;
    } catch (error) {
        console.error('Erreur récupération utilisateur:', error.message);
        // On ne bloque pas la facturation si le user service est down, on renvoie des infos minimales
        return { id: userId, nom: 'Client', prenom: '', email: '' };
    }
}

module.exports = { getUserById };