// database/db.js - Configuration et initialisation de SQLite
const Database = require('better-sqlite3');
const path = require('path');
const bcrypt = require('bcryptjs');

// Chemin vers le fichier de base de données
const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'auth.db');

// Création de la connexion à la base de données
const db = new Database(dbPath, {
    verbose: process.env.NODE_ENV === 'development' ? console.log : null
});

// Activer les contraintes de clés étrangères
db.pragma('foreign_keys = ON');

/**
 * Initialise la base de données : crée les tables si elles n'existent pas
 * et insère les données de test (seed) si la base est vide.
 */
function initDatabase() {
    console.log('🔄 Initialisation de la base de données...');

    // --- Création de la table 'users' ---
    db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      role TEXT CHECK(role IN ('admin', 'operateur', 'client')) NOT NULL DEFAULT 'client',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);

    // Création d'un index sur l'email pour accélérer les recherches
    db.exec(`CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);`);

    // --- Trigger pour mettre à jour 'updated_at' automatiquement ---
    db.exec(`
    CREATE TRIGGER IF NOT EXISTS update_users_timestamp 
    AFTER UPDATE ON users
    BEGIN
      UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;
  `);

    // --- Vérifier si la table est vide et insérer les données de test ---
    const count = db.prepare('SELECT COUNT(*) as count FROM users').get().count;

    if (count === 0) {
        console.log('🌱 Aucun utilisateur trouvé. Insertion des données de test (seed)...');
        seedDatabase();
    } else {
        console.log(`✅ Base de données déjà initialisée avec ${count} utilisateur(s).`);
    }
}

/**
 * Insère les utilisateurs de test dans la base de données.
 */
function seedDatabase() {
    const saltRounds = 10;
    const salt = bcrypt.genSaltSync(saltRounds);

    // Liste des utilisateurs à créer (conformément au cahier des charges)
    const seedUsers = [
        {
            email: 'admin@sfmc.bj',
            password: 'admin123',
            role: 'admin'
        },
        {
            email: 'operateur@sfmc.bj',
            password: 'oper123',
            role: 'operateur'
        },
        {
            email: 'client@sfmc.bj',
            password: 'client123',
            role: 'client'
        },
        {
            email: 'client2@example.com',
            password: 'client123',
            role: 'client'
        },
        {
            email: 'direction@sfmc.bj',
            password: 'direction2026',
            role: 'admin'
        }
    ];

    const insertStmt = db.prepare(
        'INSERT INTO users (email, password_hash, role) VALUES (?, ?, ?)'
    );

    // Utilisation d'une transaction pour de meilleures performances
    const insertMany = db.transaction((users) => {
        for (const user of users) {
            const hash = bcrypt.hashSync(user.password, salt);
            insertStmt.run(user.email, hash, user.role);
        }
    });

    try {
        insertMany(seedUsers);
        console.log(`✅ ${seedUsers.length} utilisateurs de test créés avec succès.`);
        console.log('   ┌─────────────────────────────────────────────────┐');
        console.log('   │  Comptes de test :                              │');
        console.log('   │  • admin@sfmc.bj / admin123 (admin)             │');
        console.log('   │  • operateur@sfmc.bj / oper123 (operateur)      │');
        console.log('   │  • client@sfmc.bj / client123 (client)          │');
        console.log('   └─────────────────────────────────────────────────┘');
    } catch (error) {
        console.error('❌ Erreur lors de l\'insertion des données de test :', error.message);
    }
}

// Exporter l'instance de base de données et la fonction d'initialisation
module.exports = {
    db,
    initDatabase
};