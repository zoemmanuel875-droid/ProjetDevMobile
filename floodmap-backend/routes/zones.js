const express = require('express');
const Zone = require('../models/Zone');
const { verifyToken } = require('../middleware/auth');
const pool = require('../database/db');

const router = express.Router();

// Récupérer toutes les zones
router.get('/', async (req, res) => {
  try {
    const zones = await Zone.getAllZones();
    res.json(zones);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Récupérer zones par risque
router.get('/risque/triees', async (req, res) => {
  try {
    const zones = await Zone.getZonesByRisk();
    res.json(zones);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Récupérer une zone spécifique
router.get('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const zone = await Zone.getZoneById(id);
    if (!zone) {
      return res.status(404).json({ error: 'Zone non trouvée' });
    }
    res.json(zone);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Récupérer historique des niveaux
router.get('/:id/historique', async (req, res) => {
  const { id } = req.params;
  try {
    const data = await Zone.getHistoricalData(id, 30);
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Mettre à jour niveau d'eau (admin)
router.put('/:id/niveau-eau', verifyToken, async (req, res) => {
  const { id } = req.params;
  const { hauteur_eau_cm } = req.body;

  try {
    // Vérifier si c'est un admin (optionnel)
    const updated = await Zone.updateWaterLevel(id, hauteur_eau_cm);
    
    // Enregistrer dans l'historique
    await pool.query(
      'INSERT INTO historique_niveaux (zone_id, hauteur_eau_cm) VALUES ($1, $2)',
      [id, hauteur_eau_cm]
    );

    res.json({ message: 'Niveau d\'eau mis à jour', zone: updated });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Ajouter aux favoris
router.post('/:id/favoris', verifyToken, async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query(
      'INSERT INTO favoris_zones (utilisateur_id, zone_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [req.user.userId, id]
    );
    res.json({ message: 'Zone ajoutée aux favoris' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Retirer des favoris
router.delete('/:id/favoris', verifyToken, async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query(
      'DELETE FROM favoris_zones WHERE utilisateur_id = $1 AND zone_id = $2',
      [req.user.userId, id]
    );
    res.json({ message: 'Zone retirée des favoris' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Récupérer favoris de l'utilisateur
router.get('/favoris/utilisateur', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT z.* FROM zones_inondables z JOIN favoris_zones f ON z.id = f.zone_id WHERE f.utilisateur_id = $1',
      [req.user.userId]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
