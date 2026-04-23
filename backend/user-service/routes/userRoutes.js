// routes/userRoutes.js - Définition des routes CRUD
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticate, authorize } = require('../middleware/authMiddleware');

// ---- Routes publiques (protégées par JWT dans l'API Gateway) ----
// Pour les tests directs, on peut activer le middleware authenticate ci-dessous.
// En production, c'est l'API Gateway qui gère l'auth, donc ces middlewares sont optionnels.

// GET /users - Liste tous les utilisateurs (accessible à admin et operateur)
router.get('/',
    // authenticate, authorize('admin', 'operateur'),  // Décommentez pour tester en direct
    userController.getAllUsers
);

// GET /users/:id - Détail d'un utilisateur
router.get('/:id',
    // authenticate,
    userController.getUserById
);

// POST /users - Créer un utilisateur (admin seulement)
router.post('/',
    // authenticate, authorize('admin'),
    userController.createUser
);

// PUT /users/:id - Modifier un utilisateur (admin ou propriétaire)
router.put('/:id',
    // authenticate, (req, res, next) => {
    //   if (req.user.role === 'admin' || req.user.id === parseInt(req.params.id)) next();
    //   else res.status(403).json({ error: 'Modification non autorisée.' });
    // },
    userController.updateUser
);

// DELETE /users/:id - Supprimer un utilisateur (admin seulement)
router.delete('/:id',
    // authenticate, authorize('admin'),
    userController.deleteUser
);

module.exports = router;