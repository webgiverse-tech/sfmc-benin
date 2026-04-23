// utils/jwtHelper.js - Fonctions utilitaires pour JWT
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

if (!JWT_SECRET) {
    console.error('❌ ERREUR FATALE : JWT_SECRET n\'est pas défini dans le fichier .env');
    process.exit(1);
}

/**
 * Génère un token JWT à partir d'un payload.
 * @param {Object} payload - Données à encoder dans le token (ex: { id, email, role })
 * @returns {string} Token JWT signé
 */
function generateToken(payload) {
    return jwt.sign(payload, JWT_SECRET, {
        expiresIn: JWT_EXPIRES_IN
    });
}

/**
 * Vérifie la validité d'un token JWT.
 * @param {string} token - Token à vérifier
 * @returns {Object|null} Payload décodé si valide, null sinon
 */
function verifyToken(token) {
    try {
        return jwt.verify(token, JWT_SECRET);
    } catch (error) {
        // Gestion silencieuse des erreurs de vérification
        if (error.name === 'TokenExpiredError') {
            console.warn('⚠️ Token expiré');
        } else if (error.name === 'JsonWebTokenError') {
            console.warn('⚠️ Token invalide');
        }
        return null;
    }
}

/**
 * Décode un token JWT sans vérifier sa signature.
 * Utile pour lire le contenu sans validation.
 * @param {string} token - Token à décoder
 * @returns {Object|null} Payload décodé ou null
 */
function decodeToken(token) {
    try {
        return jwt.decode(token);
    } catch (error) {
        return null;
    }
}

module.exports = {
    generateToken,
    verifyToken,
    decodeToken
};