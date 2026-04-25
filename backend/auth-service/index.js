// index.js - Auth Service SFMC Bénin — VERSION CORRIGÉE
// BUG FIX #3 : Un seul chargement dotenv, dans le bon ordre
require('dotenv').config({ path: '.env' });
require('dotenv').config({ path: '../.env.shared', override: false }); // fallback partagé

const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const errorHandler = require('./middleware/errorHandler');
const { initDatabase } = require('./database/db');

const app = express();
const PORT = process.env.PORT || 3001;

// --- Middlewares globaux ---
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- Initialisation de la base de données ---
initDatabase();

// --- Routes ---
app.use('/auth', authRoutes);

// --- Health check ---
app.get('/health', (req, res) => {
    res.status(200).json({
        service: 'Auth Service',
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        jwt_configured: !!process.env.JWT_SECRET
    });
});

// --- 404 ---
app.use((req, res) => {
    res.status(404).json({
        error: 'Route non trouvée',
        path: req.originalUrl,
        method: req.method,
        hint: 'Routes disponibles: POST /auth/login, POST /auth/register, POST /auth/verify, POST /auth/refresh'
    });
});

// --- Error handler ---
app.use(errorHandler);

// --- Démarrage ---
app.listen(PORT, () => {
    console.log('╔════════════════════════════════════════════╗');
    console.log('║        🔐 AUTH SERVICE SFMC BÉNIN          ║');
    console.log('╚════════════════════════════════════════════╝');
    console.log(`✅ Service démarré sur    : http://localhost:${PORT}`);
    console.log(`📁 Base de données        : ${process.env.DB_PATH || './auth.db'}`);
    console.log(`🔑 JWT Secret             : ${process.env.JWT_SECRET ? 'configuré ✓' : '❌ MANQUANT!'}`);
    console.log('══════════════════════════════════════════════');
});

process.on('SIGINT', () => {
    console.log('\n🛑 Arrêt du service Auth...');
    process.exit(0);
});
