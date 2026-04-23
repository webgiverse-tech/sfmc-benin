// index.js - Point d'entrée du User Service
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const userRoutes = require('./routes/userRoutes');
const errorHandler = require('./middleware/errorHandler');
const { initDatabase } = require('./database/db');

const app = express();
const PORT = process.env.PORT || 3002;

// --- Middlewares globaux ---
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- Initialisation de la base de données ---
initDatabase();

// --- Routes de l'API ---
app.use('/users', userRoutes);

// --- Route de santé (health check) ---
app.get('/health', (req, res) => {
    res.status(200).json({
        service: 'User Service',
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// --- 404 handler ---
app.use((req, res) => {
    res.status(404).json({
        error: 'Route non trouvée',
        path: req.originalUrl,
        method: req.method
    });
});

// --- Gestion des erreurs ---
app.use(errorHandler);

// --- Démarrage du serveur ---
app.listen(PORT, () => {
    console.log('╔════════════════════════════════════════════╗');
    console.log('║        👤 USER SERVICE SFMC BÉNIN          ║');
    console.log('╚════════════════════════════════════════════╝');
    console.log(`✅ Service démarré sur le port : ${PORT}`);
    console.log(`📁 Base de données        : ${process.env.DB_PATH}`);
    console.log(`🌐 URL locale              : http://localhost:${PORT}`);
    console.log('══════════════════════════════════════════════');
});

process.on('SIGINT', () => {
    console.log('\n🛑 Arrêt du service User...');
    process.exit(0);
});