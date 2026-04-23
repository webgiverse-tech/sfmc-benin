const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'notifications.db');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) console.error('Erreur connexion DB:', err.message);
    else console.log('📁 Connecté à la base SQLite:', dbPath);
});

function runAsync(sql, params = []) {
    return new Promise((resolve, reject) => {
        db.run(sql, params, function (err) {
            if (err) reject(err);
            else resolve({ lastID: this.lastID, changes: this.changes });
        });
    });
}

function getAsync(sql, params = []) {
    return new Promise((resolve, reject) => {
        db.get(sql, params, (err, row) => {
            if (err) reject(err);
            else resolve(row);
        });
    });
}

function allAsync(sql, params = []) {
    return new Promise((resolve, reject) => {
        db.all(sql, params, (err, rows) => {
            if (err) reject(err);
            else resolve(rows);
        });
    });
}

async function initDatabase() {
    console.log('🔄 Initialisation de la base de données notifications...');

    await runAsync(`
    CREATE TABLE IF NOT EXISTS notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      titre TEXT NOT NULL,
      message TEXT NOT NULL,
      type TEXT CHECK(type IN ('info', 'warning', 'error', 'success')) DEFAULT 'info',
      read BOOLEAN DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

    await runAsync(`CREATE INDEX IF NOT EXISTS idx_notif_user_id ON notifications(user_id)`);
    await runAsync(`CREATE INDEX IF NOT EXISTS idx_notif_read ON notifications(read)`);

    const count = await getAsync(`SELECT COUNT(*) as count FROM notifications`);
    if (count.count === 0) {
        console.log('🌱 Insertion des notifications de test...');
        await seedDatabase();
    } else {
        console.log(`✅ Base notifications déjà initialisée avec ${count.count} notification(s).`);
    }
}

async function seedDatabase() {
    const notifications = [
        { user_id: 1, titre: 'Bienvenue', message: 'Bienvenue sur SFMC Bénin !', type: 'success' },
        { user_id: 1, titre: 'Nouvelle commande', message: 'Une nouvelle commande #1001 a été créée.', type: 'info' },
        { user_id: 2, titre: 'Stock faible', message: 'Le stock de Ciment Portland est sous le seuil critique.', type: 'warning' },
        { user_id: 3, titre: 'Commande expédiée', message: 'Votre commande #1002 a été expédiée.', type: 'info' },
        { user_id: 3, titre: 'Facture disponible', message: 'Votre facture F-2026-001 est disponible.', type: 'info', read: 1 }
    ];

    for (const n of notifications) {
        await runAsync(
            `INSERT INTO notifications (user_id, titre, message, type, read) VALUES (?, ?, ?, ?, ?)`,
            [n.user_id, n.titre, n.message, n.type, n.read || 0]
        );
    }

    console.log(`✅ ${notifications.length} notifications de test créées.`);
}

module.exports = { db, runAsync, getAsync, allAsync, initDatabase };