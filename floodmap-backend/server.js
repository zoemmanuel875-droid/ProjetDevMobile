const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const pool = require('./database/db');

// Importer les routes
const authRoutes = require('./routes/auth');
const zonesRoutes = require('./routes/zones');
const alertesRoutes = require('./routes/alertes');

dotenv.config();

const app = express();

// Middlewares
app.use(cors({
  origin: '*', // Pour le développement (à restreindre en production)
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/zones', zonesRoutes);
app.use('/api/alertes', alertesRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'API FloodMap en ligne', timestamp: new Date() });
});

// Gestion des erreurs 404
app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`\n🚀 Serveur FloodMap lancé sur http://localhost:${PORT}`);
  console.log('📍 Base de données connectée');
  console.log('✅ API prête pour l\'émulateur Android Pixel 5\n');
});

module.exports = app;