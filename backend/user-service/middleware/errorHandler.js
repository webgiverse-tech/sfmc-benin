// middleware/errorHandler.js (identique à l'auth-service)
function errorHandler(err, req, res, next) {
    console.error('❌ Erreur serveur:', err.stack || err.message || err);
    const statusCode = err.statusCode || 500;
    const errorMessage = err.message || 'Erreur interne du serveur';
    res.status(statusCode).json({
        success: false,
        error: errorMessage,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
}
module.exports = errorHandler;