// database/db.js - Configuration et initialisation de la base users.db
const Database = require('better-sqlite3');
const path = require('path');

const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'users.db');
const db = new Database(dbPath, { verbose: process.env.NODE_ENV === 'development' ? console.log : null });
db.pragma('foreign_keys = ON');

function initDatabase() {
    console.log('🔄 Initialisation de la base de données utilisateurs...');

    // Table principale des utilisateurs (profil détaillé)
    db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      auth_id INTEGER UNIQUE,                     -- Référence à l'ID de l'auth-service (pour liaison future)
      nom TEXT NOT NULL,
      prenom TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      telephone TEXT,
      role TEXT CHECK(role IN ('admin', 'operateur', 'client')) NOT NULL DEFAULT 'client',
      adresse TEXT,
      avatar_url TEXT,
      actif BOOLEAN DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);

    // Index pour recherche rapide
    db.exec(`
    CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
    CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
  `);

    // Trigger pour mise à jour automatique de updated_at
    db.exec(`
    CREATE TRIGGER IF NOT EXISTS update_users_timestamp 
    AFTER UPDATE ON users
    BEGIN
      UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;
  `);

    // Vérifier si la table est vide et insérer les données de test
    const count = db.prepare('SELECT COUNT(*) as count FROM users').get().count;
    if (count === 0) {
        console.log('🌱 Insertion des profils utilisateurs de test (seed)...');
        seedDatabase();
    } else {
        console.log(`✅ Base utilisateurs déjà initialisée avec ${count} profil(s).`);
    }
}

function seedDatabase() {
    const seedUsers = [
        {
            nom: 'ADJOVI',
            prenom: 'Koffi',
            email: 'admin@sfmc.bj',
            telephone: '+229 97 12 34 56',
            role: 'admin',
            adresse: 'Cotonou, Zone Industrielle',
            avatar_url: null
        },
        {
            nom: 'HOUNKPATIN',
            prenom: 'Sèna',
            email: 'operateur@sfmc.bj',
            telephone: '+229 98 76 54 32',
            role: 'operateur',
            adresse: 'Porto-Novo, Agblangandan',
            avatar_url: null
        },
        {
            nom: 'GANGBO',
            prenom: 'Mariam',
            email: 'client@sfmc.bj',
            telephone: '+229 96 11 22 33',
            role: 'client',
            adresse: 'Abomey-Calavi, Zopah',
            avatar_url: null
        },
        {
            nom: 'DOSSOU',
            prenom: 'Yves',
            email: 'client2@example.com',
            telephone: '+229 95 44 55 66',
            role: 'client',
            adresse: 'Parakou, Centre-ville',
            avatar_url: null
        },
        {
            nom: 'MENSAH',
            prenom: 'Gisèle',
            email: 'direction@sfmc.bj',
            telephone: '+229 99 88 77 66',
            role: 'admin',
            adresse: 'Cotonou, Haie Vive',
            avatar_url: null
        }
    ];

    const insertStmt = db.prepare(`
    INSERT INTO users (nom, prenom, email, telephone, role, adresse, avatar_url)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `);

    const insertMany = db.transaction((users) => {
        for (const u of users) {
            insertStmt.run(u.nom, u.prenom, u.email, u.telephone, u.role, u.adresse, u.avatar_url);
        }
    });

    try {
        insertMany(seedUsers);
        console.log(`✅ ${seedUsers.length} profils utilisateurs créés.`);
        console.log('   ┌─────────────────────────────────────────────────┐');
        console.log('   │  Profils de test :                             │');
        console.log('   │  • admin@sfmc.bj (admin)                       │');
        console.log('   │  • operateur@sfmc.bj (operateur)               │');
        console.log('   │  • client@sfmc.bj (client)                     │');
        console.log('   └─────────────────────────────────────────────────┘');
    } catch (error) {
        console.error('❌ Erreur seed users:', error.message);
    }
}

module.exports = { db, initDatabase };