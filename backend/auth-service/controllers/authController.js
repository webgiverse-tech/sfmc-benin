// controllers/authController.js - Logique métier de l'authentification
const bcrypt = require('bcryptjs');
const { db } = require('../database/db');
const { generateToken, verifyToken } = require('../utils/jwtHelper');

/**
 * Authentifie un utilisateur et retourne un token JWT.
 * Endpoint : POST /auth/login
 */
exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        // Validation des champs requis
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                error: 'Email et mot de passe sont requis'
            });
        }

        // Recherche de l'utilisateur par email
        const user = db.prepare(`
      SELECT id, email, password_hash, role, created_at 
      FROM users 
      WHERE email = ?
    `).get(email);

        if (!user) {
            // Message générique pour ne pas indiquer si l'email existe ou non
            return res.status(401).json({
                success: false,
                error: 'Email ou mot de passe incorrect'
            });
        }

        // Vérification du mot de passe avec bcrypt
        const isPasswordValid = bcrypt.compareSync(password, user.password_hash);

        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                error: 'Email ou mot de passe incorrect'
            });
        }

        // Préparation du payload pour le JWT
        const payload = {
            id: user.id,
            email: user.email,
            role: user.role
        };

        // Génération du token
        const token = generateToken(payload);

        // Journalisation (pour audit)
        console.log(`✅ Connexion réussie : ${user.email} (${user.role})`);

        // Réponse avec le token et les infos utilisateur (sans le hash)
        res.status(200).json({
            success: true,
            message: 'Authentification réussie',
            token: token,
            user: {
                id: user.id,
                email: user.email,
                role: user.role,
                created_at: user.created_at
            }
        });

    } catch (error) {
        console.error('❌ Erreur lors du login:', error);
        next(error);
    }
};

/**
 * Enregistre un nouvel utilisateur.
 * Endpoint : POST /auth/register
 */
exports.register = async (req, res, next) => {
    try {
        const { email, password, role = 'client' } = req.body;

        // Validation des champs
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                error: 'Email et mot de passe sont requis'
            });
        }

        // Validation basique du format email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({
                success: false,
                error: 'Format d\'email invalide'
            });
        }

        // Vérifier la longueur du mot de passe (minimum 6 caractères)
        if (password.length < 6) {
            return res.status(400).json({
                success: false,
                error: 'Le mot de passe doit contenir au moins 6 caractères'
            });
        }

        // Vérifier que le rôle est valide
        const validRoles = ['admin', 'operateur', 'client'];
        if (!validRoles.includes(role)) {
            return res.status(400).json({
                success: false,
                error: 'Rôle invalide. Valeurs acceptées : admin, operateur, client'
            });
        }

        // Vérifier si l'utilisateur existe déjà
        const existingUser = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
        if (existingUser) {
            return res.status(409).json({
                success: false,
                error: 'Cet email est déjà utilisé'
            });
        }

        // Hashage du mot de passe
        const saltRounds = 10;
        const salt = bcrypt.genSaltSync(saltRounds);
        const passwordHash = bcrypt.hashSync(password, salt);

        // Insertion du nouvel utilisateur
        const insertStmt = db.prepare(`
      INSERT INTO users (email, password_hash, role) 
      VALUES (?, ?, ?)
    `);

        const result = insertStmt.run(email, passwordHash, role);
        const newUserId = result.lastInsertRowid;

        console.log(`✅ Nouvel utilisateur créé : ${email} (${role})`);

        // Génération d'un token pour connexion automatique
        const payload = {
            id: newUserId,
            email: email,
            role: role
        };
        const token = generateToken(payload);

        // Réponse
        res.status(201).json({
            success: true,
            message: 'Compte créé avec succès',
            token: token,
            user: {
                id: newUserId,
                email: email,
                role: role
            }
        });

    } catch (error) {
        console.error('❌ Erreur lors de l\'enregistrement:', error);
        next(error);
    }
};

/**
 * Vérifie la validité d'un token JWT.
 * Endpoint : POST /auth/verify
 * Utilisé par l'API Gateway pour valider les tokens entrants.
 */
exports.verify = async (req, res, next) => {
    try {
        // Récupération du token depuis l'en-tête Authorization
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                valid: false,
                error: 'Token manquant ou format invalide (Bearer token attendu)'
            });
        }

        const token = authHeader.split(' ')[1];

        // Vérification du token
        const decoded = verifyToken(token);

        if (!decoded) {
            return res.status(401).json({
                valid: false,
                error: 'Token invalide ou expiré'
            });
        }

        // Vérification supplémentaire : l'utilisateur existe-t-il toujours en base ?
        const user = db.prepare(`
      SELECT id, email, role FROM users WHERE id = ?
    `).get(decoded.id);

        if (!user) {
            return res.status(401).json({
                valid: false,
                error: 'Utilisateur associé au token introuvable'
            });
        }

        // Token valide
        res.status(200).json({
            valid: true,
            user: {
                id: user.id,
                email: user.email,
                role: user.role
            }
        });

    } catch (error) {
        console.error('❌ Erreur lors de la vérification du token:', error);
        next(error);
    }
};

/**
 * Rafraîchit un token JWT existant.
 * Endpoint : POST /auth/refresh
 * Utile pour prolonger la session sans redemander les identifiants.
 */
exports.refresh = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                error: 'Token manquant ou format invalide'
            });
        }

        const oldToken = authHeader.split(' ')[1];

        // On vérifie l'ancien token (même s'il est expiré, on veut pouvoir le rafraîchir)
        // Pour cela on décode sans vérifier l'expiration, puis on vérifie la signature.
        const decoded = verifyToken(oldToken);

        if (!decoded) {
            return res.status(401).json({
                success: false,
                error: 'Token invalide ou expiré (non rafraîchissable)'
            });
        }

        // Vérifier que l'utilisateur existe toujours
        const user = db.prepare('SELECT id, email, role FROM users WHERE id = ?').get(decoded.id);
        if (!user) {
            return res.status(401).json({
                success: false,
                error: 'Utilisateur introuvable'
            });
        }

        // Générer un nouveau token avec les mêmes informations
        const payload = {
            id: user.id,
            email: user.email,
            role: user.role
        };

        const newToken = generateToken(payload);

        console.log(`🔄 Token rafraîchi pour : ${user.email}`);

        res.status(200).json({
            success: true,
            message: 'Token rafraîchi avec succès',
            token: newToken
        });

    } catch (error) {
        console.error('❌ Erreur lors du rafraîchissement du token:', error);
        next(error);
    }
};