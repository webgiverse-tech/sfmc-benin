// middleware/errorHandler.js — Gestionnaire d'erreurs global
const errorHandler = (err, req, res, next) => {
    console.error('❌ Erreur non gérée :', err.stack || err.message);

    // Erreur SQLite de contrainte unique (email déjà utilisé)
    if (err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
        return res.status(409).json({
            success: false,
            error: 'Cet email est déjà utilisé'
        });
    }

    // Erreur JWT
    if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
        return res.status(401).json({
            success: false,
            error: 'Token invalide ou expiré'
        });
    }

    // Erreur générique
    res.status(err.status || 500).json({
        success: false,
        error: err.message || 'Erreur interne du serveur'
    });
};

module.exports = errorHandler;
