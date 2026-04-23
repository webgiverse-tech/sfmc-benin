function errorHandler(err, req, res, next) {
    console.error('❌ Erreur:', err.stack || err.message);
    res.status(err.statusCode || 500).json({ success: false, error: err.message || 'Erreur serveur' });
}
module.exports = errorHandler;