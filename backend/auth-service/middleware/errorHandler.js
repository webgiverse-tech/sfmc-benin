// middleware/errorHandler.js - Gestionnaire centralisé des erreurs
/**
 * Middleware de gestion des erreurs.
 * Capture toutes les erreurs et renvoie une réponse JSON formatée.
 */
function errorHandler(err, req, res, next) {
    console.error('❌ Erreur serveur:', err.stack || err.message || err);

    // Déterminer le code d'erreur HTTP approprié
    const statusCode = err.statusCode || 500;
    const errorMessage = err.message || 'Erreur interne du serveur';

    res.status(statusCode).json({
        success: false,
        error: errorMessage,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
}

module.exports = errorHandler;