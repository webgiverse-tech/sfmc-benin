require('dotenv').config();
require('dotenv').config({ path: '.env' });
require('dotenv').config({ path: '../.env.shared', override: false });
const express = require('express');
const cors = require('cors');
const reportingRoutes = require('./routes/reportingRoutes');
const errorHandler = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3009;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/reporting', reportingRoutes);

app.get('/health', (req, res) => {
    res.status(200).json({
        service: 'Reporting Service',
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
    console.log('║     📊 REPORTING SERVICE SFMC BÉNIN        ║');
    console.log('╚════════════════════════════════════════════╝');
    console.log(`✅ Service démarré sur le port : ${PORT}`);
    console.log(`🌐 URL locale              : http://localhost:${PORT}`);
    console.log('══════════════════════════════════════════════');
});

process.on('SIGINT', () => {
    console.log('\n🛑 Arrêt du service Reporting...');
    process.exit(0);
});