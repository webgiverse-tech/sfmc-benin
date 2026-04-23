// middleware/authMiddleware.js - Protection des routes (optionnel pour tests directs)
const { verifyToken, extractToken } = require('../utils/jwtHelper');

/**
 * Middleware d'authentification.
 * À utiliser pour protéger les endpoints lorsque l'API Gateway n'est pas utilisée.
 * Vérifie la présence et la validité du JWT.
 */
function authenticate(req, res, next) {
    const token = extractToken(req);

    if (!token) {
        return res.status(401).json({
            success: false,
            error: 'Accès non autorisé. Token manquant.'
        });
    }

    const decoded = verifyToken(token);
    if (!decoded) {
        return res.status(401).json({
            success: false,
            error: 'Token invalide ou expiré.'
        });
    }

    // Ajoute les infos utilisateur à la requête pour les contrôleurs
    req.user = decoded;
    next();
}

/**
 * Middleware d'autorisation basé sur le rôle.
 * @param {string[]} allowedRoles - Liste des rôles autorisés
 */
function authorize(...allowedRoles) {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ error: 'Authentification requise.' });
        }
        if (!allowedRoles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                error: 'Accès interdit. Rôle insuffisant.'
            });
        }
        next();
    };
}

module.exports = { authenticate, authorize };