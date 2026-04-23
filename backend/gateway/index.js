require('dotenv').config();
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET;

app.use(cors());
app.use(express.json());

// Services
const services = {
    auth: 'http://localhost:3001',
    users: 'http://localhost:3002',
    products: 'http://localhost:3003',
    inventory: 'http://localhost:3004',
    orders: 'http://localhost:3005',
    production: 'http://localhost:3006',
    billing: 'http://localhost:3007',
    notif: 'http://localhost:3008',
    reporting: 'http://localhost:3009'
};

// Middleware d'authentification (appliqué après les routes publiques)
const authenticate = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer '))
        return res.status(401).json({ error: 'Token manquant' });
    const token = authHeader.split(' ')[1];
    try {
        req.user = jwt.verify(token, JWT_SECRET);
        next();
    } catch (err) {
        return res.status(401).json({ error: 'Token invalide ou expiré' });
    }
};

// Routes publiques (placées AVANT authenticate)
app.post('/api/auth/login', createProxyMiddleware({ target: services.auth, changeOrigin: true }));
app.post('/api/auth/register', createProxyMiddleware({ target: services.auth, changeOrigin: true }));
app.get('/health', (req, res) => res.json({ service: 'API Gateway', status: 'healthy' }));

// Appliquer authenticate à toutes les autres routes
app.use(authenticate);

// Proxy pour les autres services
app.use('/api/auth', createProxyMiddleware({ target: services.auth, changeOrigin: true }));
app.use('/api/users', createProxyMiddleware({ target: services.users, changeOrigin: true }));
app.use('/api/products', createProxyMiddleware({ target: services.products, changeOrigin: true }));
app.use('/api/inventory', createProxyMiddleware({ target: services.inventory, changeOrigin: true }));
app.use('/api/orders', createProxyMiddleware({ target: services.orders, changeOrigin: true }));
app.use('/api/production', createProxyMiddleware({ target: services.production, changeOrigin: true }));
app.use('/api/billing', createProxyMiddleware({ target: services.billing, changeOrigin: true }));
app.use('/api/notif', createProxyMiddleware({ target: services.notif, changeOrigin: true }));
app.use('/api/reporting', createProxyMiddleware({ target: services.reporting, changeOrigin: true }));

// 404
app.use((req, res) => res.status(404).json({ error: 'Route non trouvée' }));

app.listen(PORT, () => console.log(`🚀 API Gateway démarrée sur http://localhost:${PORT}`));