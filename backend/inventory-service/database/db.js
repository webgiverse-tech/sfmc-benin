// inventory-service/database/db.js — Corrigé (contrainte UNIQUE + trigger fixé)
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'inventory.db');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) console.error('❌ Erreur connexion DB:', err.message);
    else console.log('📁 Connecté à la base SQLite:', dbPath);
});

db.run('PRAGMA journal_mode = WAL;');
db.run('PRAGMA foreign_keys = ON;');

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
    console.log('🔄 Initialisation de la base de données inventaire...');

    // Table des entrepôts
    await runAsync(`
        CREATE TABLE IF NOT EXISTS warehouses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            localisation TEXT,
            capacite INTEGER,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `);

    // Table des stocks — CORRECTION: contrainte UNIQUE sur (product_id, warehouse_id)
    await runAsync(`
        CREATE TABLE IF NOT EXISTS stock (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            warehouse_id INTEGER NOT NULL,
            quantity REAL NOT NULL DEFAULT 0,
            seuil_critique REAL DEFAULT 0,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(product_id, warehouse_id),
            FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
        )
    `);

    // Table des mouvements de stock
    await runAsync(`
        CREATE TABLE IF NOT EXISTS stock_movements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            warehouse_id INTEGER NOT NULL,
            type TEXT CHECK(type IN ('IN', 'OUT')) NOT NULL,
            quantity REAL NOT NULL,
            reason TEXT,
            date DATETIME DEFAULT CURRENT_TIMESTAMP,
            user_id INTEGER,
            FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
        )
    `);

    // Table virtuelle des produits (pour les jointures — les produits viennent du product-service)
    // On crée une table locale légère pour le cache des noms
    await runAsync(`
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY,
            nom TEXT NOT NULL,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `);

    // CORRECTION: Trigger avec ON CONFLICT qui fonctionne grâce à la contrainte UNIQUE
    await runAsync(`
        CREATE TRIGGER IF NOT EXISTS update_stock_after_movement
        AFTER INSERT ON stock_movements
        BEGIN
            INSERT INTO stock (product_id, warehouse_id, quantity, seuil_critique)
            VALUES (
                NEW.product_id,
                NEW.warehouse_id,
                CASE WHEN NEW.type = 'IN' THEN NEW.quantity ELSE -NEW.quantity END,
                0
            )
            ON CONFLICT(product_id, warehouse_id) DO UPDATE SET
                quantity = quantity + CASE WHEN NEW.type = 'IN' THEN NEW.quantity ELSE -NEW.quantity END,
                updated_at = CURRENT_TIMESTAMP;
        END
    `);

    const warehouseCount = await getAsync('SELECT COUNT(*) as count FROM warehouses');
    if (warehouseCount.count === 0) {
        console.log('🌱 Insertion des données de test inventaire...');
        await seedDatabase();
    } else {
        console.log('✅ Base inventaire déjà initialisée.');
    }
}

async function seedDatabase() {
    // Entrepôts
    await runAsync(
        'INSERT INTO warehouses (nom, localisation, capacite) VALUES (?, ?, ?)',
        ['Entrepôt Principal Cotonou', 'Zone Industrielle, Cotonou', 10000]
    );
    await runAsync(
        'INSERT INTO warehouses (nom, localisation, capacite) VALUES (?, ?, ?)',
        ['Entrepôt Secondaire Porto-Novo', 'Agblangandan, Porto-Novo', 5000]
    );

    // Insérer les noms de produits en cache local
    const produits = [
        [1, 'Ciment Portland 50kg'],
        [2, 'Fer à béton 10mm'],
        [3, 'Brique rouge'],
        [4, 'Gravier 5/15'],
        [5, 'Sable fin'],
        [6, 'Parpaing creux']
    ];
    for (const [id, nom] of produits) {
        await runAsync('INSERT OR IGNORE INTO products (id, nom) VALUES (?, ?)', [id, nom]);
    }

    // Stocks initiaux via INSERT direct (pas de trigger pour le seed)
    const stocks = [
        [1, 1, 500, 100],   // Ciment — Entrepôt Cotonou
        [2, 1, 2000, 500],   // Fer
        [3, 1, 10000, 2000],  // Brique
        [4, 2, 50, 10],    // Gravier — Entrepôt Porto-Novo
        [5, 2, 80, 15],    // Sable
        [6, 1, 3000, 500]    // Parpaing
    ];
    for (const [pid, wid, qty, seuil] of stocks) {
        await runAsync(
            'INSERT OR IGNORE INTO stock (product_id, warehouse_id, quantity, seuil_critique) VALUES (?, ?, ?, ?)',
            [pid, wid, qty, seuil]
        );
    }
    console.log('✅ Entrepôts et stocks initiaux créés.');
}

module.exports = { db, runAsync, getAsync, allAsync, initDatabase };
