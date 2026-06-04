const express = require('express');
const Alert = require('../models/Alert');
const { verifyToken } = require('../middleware/auth');

const router = express.Router();

// Récupérer toutes les alertes
router.get('/', async (req, res) => {
  try {
    const alertes = await Alert.getAllAlerts();
    res.json(alertes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Récupérer alertes d'une zone
router.get('/zone/:zoneId', async (req, res) => {
  const { zoneId } = req.params;
  try {
    const alertes = await Alert.getAlertsByZone(zoneId);
    res.json(alertes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Récupérer alertes non lues de l'utilisateur
router.get('/utilisateur/non-lues', verifyToken, async (req, res) => {
  try {
    const alertes = await Alert.getUnreadAlerts(req.user.userId);
    res.json(alertes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Créer une alerte
router.post('/', verifyToken, async (req, res) => {
  const { zone_id, message, niveau } = req.body;

  if (!zone_id || !message || !niveau) {
    return res.status(400).json({ error: 'Champs requis manquants' });
  }

  try {
    const alerte = await Alert.createAlert(zone_id, message, niveau, req.user.userId);
    res.status(201).json(alerte);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Marquer comme lue
router.put('/:id/lue', verifyToken, async (req, res) => {
  const { id } = req.params;
  try {
    await Alert.markAsRead(id);
    res.json({ message: 'Alerte marquée comme lue' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
