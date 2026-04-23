// controllers/userController.js - Logique métier CRUD utilisateurs
const { db } = require('../database/db');

/**
 * Récupère tous les utilisateurs avec filtres optionnels.
 * GET /users?role=admin&actif=true
 */
exports.getAllUsers = (req, res, next) => {
    try {
        const { role, actif, search } = req.query;

        let query = 'SELECT * FROM users WHERE 1=1';
        const params = [];

        if (role) {
            query += ' AND role = ?';
            params.push(role);
        }
        if (actif !== undefined) {
            query += ' AND actif = ?';
            params.push(actif === 'true' ? 1 : 0);
        }
        if (search) {
            query += ' AND (nom LIKE ? OR prenom LIKE ? OR email LIKE ? OR telephone LIKE ?)';
            const searchPattern = `%${search}%`;
            params.push(searchPattern, searchPattern, searchPattern, searchPattern);
        }

        query += ' ORDER BY nom, prenom';

        const stmt = db.prepare(query);
        const users = stmt.all(...params);

        res.status(200).json({
            success: true,
            count: users.length,
            data: users
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Récupère un utilisateur par son ID.
 * GET /users/:id
 */
exports.getUserById = (req, res, next) => {
    try {
        const { id } = req.params;
        const user = db.prepare('SELECT * FROM users WHERE id = ?').get(id);

        if (!user) {
            return res.status(404).json({
                success: false,
                error: 'Utilisateur non trouvé.'
            });
        }

        res.status(200).json({
            success: true,
            data: user
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Crée un nouvel utilisateur.
 * POST /users
 */
exports.createUser = (req, res, next) => {
    try {
        const { nom, prenom, email, telephone, role, adresse, avatar_url, actif } = req.body;

        // Validation des champs obligatoires
        if (!nom || !prenom || !email || !role) {
            return res.status(400).json({
                success: false,
                error: 'Les champs nom, prenom, email et role sont requis.'
            });
        }

        // Vérifier que l'email n'existe pas déjà
        const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
        if (existing) {
            return res.status(409).json({
                success: false,
                error: 'Un utilisateur avec cet email existe déjà.'
            });
        }

        // Vérifier le rôle valide
        const validRoles = ['admin', 'operateur', 'client'];
        if (!validRoles.includes(role)) {
            return res.status(400).json({
                success: false,
                error: `Rôle invalide. Valeurs acceptées : ${validRoles.join(', ')}`
            });
        }

        const stmt = db.prepare(`
      INSERT INTO users (nom, prenom, email, telephone, role, adresse, avatar_url, actif)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);

        const result = stmt.run(
            nom,
            prenom,
            email,
            telephone || null,
            role,
            adresse || null,
            avatar_url || null,
            actif !== undefined ? (actif ? 1 : 0) : 1
        );

        const newUser = db.prepare('SELECT * FROM users WHERE id = ?').get(result.lastInsertRowid);

        console.log(`✅ Nouvel utilisateur créé : ${email} (${role})`);

        res.status(201).json({
            success: true,
            message: 'Utilisateur créé avec succès.',
            data: newUser
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Met à jour un utilisateur existant.
 * PUT /users/:id
 */
exports.updateUser = (req, res, next) => {
    try {
        const { id } = req.params;
        const { nom, prenom, email, telephone, role, adresse, avatar_url, actif } = req.body;

        // Vérifier que l'utilisateur existe
        const existing = db.prepare('SELECT * FROM users WHERE id = ?').get(id);
        if (!existing) {
            return res.status(404).json({
                success: false,
                error: 'Utilisateur non trouvé.'
            });
        }

        // Vérifier l'unicité de l'email si modifié
        if (email && email !== existing.email) {
            const emailExists = db.prepare('SELECT id FROM users WHERE email = ? AND id != ?').get(email, id);
            if (emailExists) {
                return res.status(409).json({
                    success: false,
                    error: 'Cet email est déjà utilisé par un autre utilisateur.'
                });
            }
        }

        // Valider le rôle si fourni
        if (role) {
            const validRoles = ['admin', 'operateur', 'client'];
            if (!validRoles.includes(role)) {
                return res.status(400).json({
                    success: false,
                    error: `Rôle invalide. Valeurs acceptées : ${validRoles.join(', ')}`
                });
            }
        }

        const stmt = db.prepare(`
      UPDATE users SET
        nom = COALESCE(?, nom),
        prenom = COALESCE(?, prenom),
        email = COALESCE(?, email),
        telephone = COALESCE(?, telephone),
        role = COALESCE(?, role),
        adresse = COALESCE(?, adresse),
        avatar_url = COALESCE(?, avatar_url),
        actif = COALESCE(?, actif),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `);

        stmt.run(
            nom || null,
            prenom || null,
            email || null,
            telephone || null,
            role || null,
            adresse || null,
            avatar_url || null,
            actif !== undefined ? (actif ? 1 : 0) : null,
            id
        );

        const updatedUser = db.prepare('SELECT * FROM users WHERE id = ?').get(id);

        console.log(`✏️ Utilisateur mis à jour : ID ${id}`);

        res.status(200).json({
            success: true,
            message: 'Utilisateur mis à jour avec succès.',
            data: updatedUser
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Supprime un utilisateur.
 * DELETE /users/:id
 */
exports.deleteUser = (req, res, next) => {
    try {
        const { id } = req.params;

        const existing = db.prepare('SELECT id FROM users WHERE id = ?').get(id);
        if (!existing) {
            return res.status(404).json({
                success: false,
                error: 'Utilisateur non trouvé.'
            });
        }

        db.prepare('DELETE FROM users WHERE id = ?').run(id);

        console.log(`🗑️ Utilisateur supprimé : ID ${id}`);

        res.status(200).json({
            success: true,
            message: 'Utilisateur supprimé avec succès.'
        });
    } catch (error) {
        next(error);
    }
};