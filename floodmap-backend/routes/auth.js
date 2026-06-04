const express = require('express');
const User = require('../models/User');
const { generateToken, verifyToken } = require('../middleware/auth');

const router = express.Router();

// Inscription
router.post('/register', async (req, res) => {
  const { nom, email, mot_de_passe, telephone } = req.body;

  if (!nom || !email || !mot_de_passe) {
    return res.status(400).json({ error: 'Champs requis manquants' });
  }

  try {
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({ error: 'Email déjà utilisé' });
    }

    const newUser = await User.create(nom, email, mot_de_passe, telephone);
    const token = generateToken(newUser.id, newUser.email);

    res.status(201).json({
      message: 'Utilisateur créé avec succès',
      user: newUser,
      token
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Connexion
router.post('/login', async (req, res) => {
  const { email, mot_de_passe } = req.body;

  if (!email || !mot_de_passe) {
    return res.status(400).json({ error: 'Email et mot de passe requis' });
  }

  try {
    const user = await User.verifyPassword(email, mot_de_passe);
    if (!user) {
      return res.status(401).json({ error: 'Identifiants invalides' });
    }

    const token = generateToken(user.id, user.email);
    res.json({
      message: 'Connexion réussie',
      user: { id: user.id, nom: user.nom, email: user.email },
      token
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Récupérer profil
router.get('/profile', verifyToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Mettre à jour profil
router.put('/profile', verifyToken, async (req, res) => {
  const { nom, telephone } = req.body;

  try {
    const updated = await User.updateProfile(req.user.userId, nom, telephone);
    res.json({ message: 'Profil mis à jour', user: updated });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
