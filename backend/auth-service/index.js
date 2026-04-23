// index.js - Point d'entrée du Auth Service
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const errorHandler = require('./middleware/errorHandler');
const { initDatabase } = require('./database/db');

const app = express();
const PORT = process.env.PORT || 3001;

// --- Middlewares globaux ---
app.use(cors());                         // Autorise les requêtes cross-origin
app.use(express.json());                 // Parse le JSON entrant
app.use(express.urlencoded({ extended: true })); // Parse les formulaires URL-encoded

// --- Initialisation de la base de données ---
// Cette fonction crée les tables et insère les données de test si la base est vide
initDatabase();

// --- Routes de l'API ---
app.use('/auth', authRoutes);

// --- Route de santé (health check) ---
app.get('/health', (req, res) => {
    res.status(200).json({
        service: 'Auth Service',
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// --- Gestion des routes non trouvées (404) ---
app.use((req, res, next) => {
    res.status(404).json({
        error: 'Route non trouvée',
        path: req.originalUrl,
        method: req.method
    });
});

// --- Middleware de gestion des erreurs (doit être le dernier) ---
app.use(errorHandler);

// --- Démarrage du serveur ---
app.listen(PORT, () => {
    console.log('╔════════════════════════════════════════════╗');
    console.log('║        🔐 AUTH SERVICE SFMC BÉNIN          ║');
    console.log('╚════════════════════════════════════════════╝');
    console.log(`✅ Service démarré sur le port : ${PORT}`);
    console.log(`📁 Base de données        : ${process.env.DB_PATH}`);
    console.log(`🔑 JWT Secret configuré    : ${process.env.JWT_SECRET ? 'Oui' : 'Non'}`);
    console.log(`🌐 URL locale              : http://localhost:${PORT}`);
    console.log('══════════════════════════════════════════════');
});

// Gestion propre de l'arrêt
process.on('SIGINT', () => {
    console.log('\n🛑 Arrêt du service Auth...');
    process.exit(0);
});