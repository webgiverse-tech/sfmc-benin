require('dotenv').config();
const express = require('express');
const cors = require('cors');
const productionRoutes = require('./routes/productionRoutes');
const errorHandler = require('./middleware/errorHandler');
const { initDatabase } = require('./database/db');

const app = express();
const PORT = process.env.PORT || 3006;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

initDatabase();

app.use('/production', productionRoutes);

app.get('/health', (req, res) => {
    res.status(200).json({
        service: 'Production Service',
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

app.use((req, res) => {
    res.status(404).json({ error: 'Route non trouvée', path: req.originalUrl });
});

app.use(errorHandler);

app.listen(PORT, () => {
    console.log('╔════════════════════════════════════════════╗');
    console.log('║      🏭 PRODUCTION SERVICE SFMC BÉNIN      ║');
    console.log('╚════════════════════════════════════════════╝');
    console.log(`✅ Service démarré sur le port : ${PORT}`);
    console.log(`📁 Base de données        : ${process.env.DB_PATH}`);
    console.log(`🌐 URL locale              : http://localhost:${PORT}`);
    console.log('══════════════════════════════════════════════');
});

process.on('SIGINT', () => {
    console.log('\n🛑 Arrêt du service Production...');
    process.exit(0);
});