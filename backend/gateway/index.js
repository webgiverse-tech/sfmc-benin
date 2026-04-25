// gateway/index.js — API Gateway SFMC Bénin — VERSION CORRIGÉE FINALE
require('dotenv').config({ path: '.env' });
require('dotenv').config({ path: '../.env.shared', override: false });

const express = require('express');
const { createProxyMiddleware, fixRequestBody } = require('http-proxy-middleware');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
    console.error('❌ ERREUR FATALE : JWT_SECRET manquant dans .env');
    console.error('💡 Solution : Créez le fichier backend/gateway/.env avec JWT_SECRET=sfmc_benin_super_secret_jwt_2026_key');
    process.exit(1);
}

// ─── CORS ────────────────────────────────────────────────────────────────────
app.use(cors({
    origin: function (origin, callback) {
        // Accepte toutes les origines localhost (Flutter web tourne sur un port variable)
        if (!origin || origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
            callback(null, true);
        } else {
            callback(new Error('Origine non autorisée par CORS'));
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: false
}));

// ─── BUG FIX #4 : express.json() AVANT les proxies ──────────────────────────
// Sans cela, le body des requêtes POST est perdu lors du proxying
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ─── Route de santé ───────────────────────────────────────────────────────────
app.get('/health', (req, res) => {
    res.json({
        service: 'API Gateway SFMC Bénin',
        status: 'healthy',
        timestamp: new Date().toISOString(),
        jwt_configured: !!JWT_SECRET,
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

// ─── Services cibles ──────────────────────────────────────────────────────────
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

// ─── BUG FIX #1 : Factory proxy corrigée pour http-proxy-middleware v3 ───────
// pathRewrite doit être un OBJET (clé regex → valeur), pas une fonction
// Ex : /api/auth/login → /auth/login  sur le Auth Service :3001
function makeProxy(target, apiPrefix) {
    return createProxyMiddleware({
        target,
        changeOrigin: true,
        // Syntaxe objet requise en v3 : supprime le préfixe /api/xxx
        pathRewrite: {
            [`^/api/${apiPrefix}`]: `/${apiPrefix}`
        },
        on: {
            // BUG FIX #4 : fixRequestBody répare le body après express.json()
            proxyReq: fixRequestBody,
            error: (err, req, res) => {
                console.error(`❌ Proxy error → ${target} : ${err.message}`);
                if (!res.headersSent) {
                    res.status(502).json({
                        success: false,
                        error: 'Service temporairement indisponible',
                        service: target,
                        detail: err.message
                    });
                }
            }
        }
    });
}

// ─── Middleware JWT ────────────────────────────────────────────────────────────
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

// ─── ROUTES PUBLIQUES (sans authentification) ─────────────────────────────────
// Ces routes doivent être AVANT le middleware authenticate
app.use('/api/auth/login', makeProxy(services.auth, 'auth'));
app.use('/api/auth/register', makeProxy(services.auth, 'auth'));

// ─── AUTH MIDDLEWARE (toutes les routes suivantes sont protégées) ─────────────
app.use(authenticate);

// ─── ROUTES PROTÉGÉES ─────────────────────────────────────────────────────────
app.use('/api/auth', makeProxy(services.auth, 'auth'));
app.use('/api/users', makeProxy(services.users, 'users'));
app.use('/api/products', makeProxy(services.products, 'products'));
app.use('/api/inventory', makeProxy(services.inventory, 'inventory'));
app.use('/api/orders', makeProxy(services.orders, 'orders'));
app.use('/api/production', makeProxy(services.production, 'production'));
app.use('/api/billing', makeProxy(services.billing, 'billing'));

// BUG FIX #5 : Le frontend appelle /api/notifications/* ET /api/notif/*
// On expose les DEUX préfixes pour pointer vers le même service :3008
app.use('/api/notifications', makeProxy(services.notif, 'notifications'));
app.use('/api/notif', makeProxy(services.notif, 'notif'));

app.use('/api/reporting', makeProxy(services.reporting, 'reporting'));

// ─── 404 ──────────────────────────────────────────────────────────────────────
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: `Route non trouvée : ${req.method} ${req.originalUrl}`,
        hint: 'Vérifiez que le service cible est bien démarré'
    });
});

// ─── Démarrage ─────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
    console.log('╔══════════════════════════════════════════════╗');
    console.log('║       🌐 API GATEWAY SFMC BÉNIN              ║');
    console.log('╚══════════════════════════════════════════════╝');
    console.log(`✅ Gateway démarrée       : http://localhost:${PORT}`);
    console.log(`🔑 JWT Secret             : configuré ✓`);
    console.log(`🛡️  Routes publiques       : /api/auth/login, /api/auth/register`);
    console.log(`📡 Health check           : http://localhost:${PORT}/health`);
    console.log('══════════════════════════════════════════════════');
});

process.on('SIGINT', () => {
    console.log('\n🛑 Arrêt du Gateway...');
    process.exit(0);
});
