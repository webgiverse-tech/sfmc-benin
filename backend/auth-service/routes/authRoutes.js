// routes/authRoutes.js - Définition des routes du Auth Service
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

/**
 * Routes publiques d'authentification
 * Toutes les routes sont préfixées par /auth dans index.js
 */

// POST /auth/login - Authentification et obtention du token
router.post('/login', authController.login);

// POST /auth/register - Création d'un nouveau compte
router.post('/register', authController.register);

// POST /auth/verify - Vérification de la validité d'un token
router.post('/verify', authController.verify);

// POST /auth/refresh - Rafraîchissement d'un token
router.post('/refresh', authController.refresh);

module.exports = router;