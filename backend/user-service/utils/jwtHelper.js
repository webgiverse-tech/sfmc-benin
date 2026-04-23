// utils/jwtHelper.js - Fonctions pour vérifier et décoder les JWT
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
    console.error('❌ JWT_SECRET non défini dans .env');
    process.exit(1);
}

/**
 * Vérifie un token et retourne le payload décodé.
 * @param {string} token - Token JWT
 * @returns {Object|null} Payload ou null si invalide/expiré
 */
function verifyToken(token) {
    try {
        return jwt.verify(token, JWT_SECRET);
    } catch (error) {
        return null;
    }
}

/**
 * Extrait le token du header Authorization.
 * @param {Object} req - Requête Express
 * @returns {string|null} Token ou null
 */
function extractToken(req) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return null;
    }
    return authHeader.split(' ')[1];
}

module.exports = { verifyToken, extractToken };