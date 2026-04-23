function errorHandler(err, req, res, next) {
    console.error('❌ Erreur:', err.stack || err.message);
    const status = err.response?.status || 500;
    res.status(status).json({ success: false, error: err.message || 'Erreur serveur' });
}
module.exports = errorHandler;