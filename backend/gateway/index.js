// gateway/index.js — API Gateway SFMC Bénin (Express 4 + http-proxy-middleware v3)
require('dotenv').config();
const express = require('express');
const { createProxyMiddleware, fixRequestBody } = require('http-proxy-middleware');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
    console.error('❌ ERREUR FATALE : JWT_SECRET manquant dans .env');
    process.exit(1);
}

// ─── CORS ─────────────────────────────────────────────────────────────────────
app.use(cors({
    origin: function (origin, callback) {
        // Autoriser les requêtes sans origine (outils comme curl, Postman)
        // et toutes les origines localhost / 127.0.0.1 (quel que soit le port)
        if (!origin || origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
            callback(null, true);
        } else {
            callback(new Error('Origine non autorisée par CORS'));
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: false   // Pas nécessaire pour l'authentification par token Bearer
}));

// ─── Body parsing (AVANT les proxies) ─────────────────────────────────────────
// NOTE IMPORTANTE: on NE parse PAS le body globalement ici,
// sinon le proxy ne peut plus le retransmettre.
// On le parse uniquement pour la route /health et l'authentification locale.

// ─── Routes de santé (aucun auth requis) ──────────────────────────────────────
app.get('/health', (req, res) => {
    res.json({
        service: 'API Gateway SFMC Bénin',
        status: 'healthy',
        timestamp: new Date().toISOString(),
        services: {
            auth: 'http://localhost:3001',
            users: 'http://localhost:3002',
            products: 'http://localhost:3003',
            inventory: 'http://localhost:3004',
            orders: 'http://localhost:3005',
            production: 'http://localhost:3006',
            billing: 'http://localhost:3007',
            notif: 'http://localhost:3008',
            reporting: 'http://localhost:3009'
        }
    });
});

// ─── Définition des services cibles ───────────────────────────────────────────
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

// ─── Fonction factory pour créer un proxy sécurisé ────────────────────────────
function makeProxy(target, pathRewrite = {}) {
    return createProxyMiddleware({
        target,
        changeOrigin: true,
        pathRewrite,
        on: {
            proxyReq: fixRequestBody,   // Fix critique pour Express 4 + body parsé
            error: (err, req, res) => {
                console.error(`❌ Proxy error → ${target}:`, err.message);
                if (!res.headersSent) {
                    res.status(502).json({
                        success: false,
                        error: 'Service temporairement indisponible',
                        service: target
                    });
                }
            }
        }
    });
}

// ─── Middleware d'authentification JWT ────────────────────────────────────────
const authenticate = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ success: false, error: 'Token manquant ou invalide' });
    }
    const token = authHeader.split(' ')[1];
    try {
        req.user = jwt.verify(token, JWT_SECRET);
        next();
    } catch (err) {
        const msg = err.name === 'TokenExpiredError' ? 'Token expiré' : 'Token invalide';
        return res.status(401).json({ success: false, error: msg });
    }
};

// ─── ROUTES PUBLIQUES (sans authentification) ──────────────────────────────────
// Ces routes DOIVENT être définies avant l'application de authenticate
app.use('/api/auth/login', makeProxy(services.auth));
app.use('/api/auth/register', makeProxy(services.auth));

// ─── MIDDLEWARE AUTH (toutes les routes suivantes sont protégées) ──────────────
app.use(authenticate);

// ─── ROUTES PROTÉGÉES ──────────────────────────────────────────────────────────
app.use('/api/auth', makeProxy(services.auth));
app.use('/api/users', makeProxy(services.users));
app.use('/api/products', makeProxy(services.products));
app.use('/api/inventory', makeProxy(services.inventory));
app.use('/api/orders', makeProxy(services.orders));
app.use('/api/production', makeProxy(services.production));
app.use('/api/billing', makeProxy(services.billing));
app.use('/api/notif', makeProxy(services.notif));
app.use('/api/reporting', makeProxy(services.reporting));

// ─── 404 ──────────────────────────────────────────────────────────────────────
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: `Route non trouvée : ${req.method} ${req.originalUrl}`
    });
});

// ─── Démarrage ─────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
    console.log('╔══════════════════════════════════════════════╗');
    console.log('║       🌐 API GATEWAY SFMC BÉNIN              ║');
    console.log('╚══════════════════════════════════════════════╝');
    console.log(`✅ Gateway démarrée sur : http://localhost:${PORT}`);
    console.log(`🔑 JWT Secret           : configuré`);
    console.log(`🛡️  Routes publiques     : /api/auth/login, /api/auth/register`);
    console.log('══════════════════════════════════════════════════');
});

process.on('SIGINT', () => {
    console.log('\n🛑 Arrêt du Gateway...');
    process.exit(0);
});
