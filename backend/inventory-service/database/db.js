const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'inventory.db');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) console.error('Erreur connexion DB:', err.message);
    else console.log('📁 Connecté à la base SQLite:', dbPath);
});

// Helpers asynchrones
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

    // Table des stocks par produit/entrepôt
    await runAsync(`
    CREATE TABLE IF NOT EXISTS stock (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL,
      warehouse_id INTEGER NOT NULL,
      quantity REAL NOT NULL DEFAULT 0,
      seuil_critique REAL DEFAULT 0,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
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

    // Trigger pour mise à jour de stock après mouvement
    db.exec(`
    CREATE TRIGGER IF NOT EXISTS update_stock_after_movement
    AFTER INSERT ON stock_movements
    BEGIN
      INSERT INTO stock (product_id, warehouse_id, quantity, seuil_critique)
      VALUES (NEW.product_id, NEW.warehouse_id, 
        CASE WHEN NEW.type = 'IN' THEN NEW.quantity ELSE -NEW.quantity END,
        0)
      ON CONFLICT(product_id, warehouse_id) DO UPDATE SET
        quantity = quantity + CASE WHEN NEW.type = 'IN' THEN NEW.quantity ELSE -NEW.quantity END,
        updated_at = CURRENT_TIMESTAMP;
    END;
  `);

    const warehouseCount = await getAsync(`SELECT COUNT(*) as count FROM warehouses`);
    if (warehouseCount.count === 0) {
        console.log('🌱 Insertion des données de test...');
        await seedDatabase();
    } else {
        console.log(`✅ Base inventaire déjà initialisée.`);
    }
}

async function seedDatabase() {
    // Entrepôts
    await runAsync(`INSERT INTO warehouses (nom, localisation, capacite) VALUES (?, ?, ?)`,
        ['Entrepôt Principal Cotonou', 'Zone Industrielle, Cotonou', 10000]);
    await runAsync(`INSERT INTO warehouses (nom, localisation, capacite) VALUES (?, ?, ?)`,
        ['Entrepôt Secondaire Porto-Novo', 'Agblangandan, Porto-Novo', 5000]);

    // Stocks initiaux pour les 6 produits (product_id 1 à 6)
    const stocks = [
        { product_id: 1, warehouse_id: 1, quantity: 500, seuil: 100 },  // Ciment
        { product_id: 2, warehouse_id: 1, quantity: 2000, seuil: 500 }, // Fer
        { product_id: 3, warehouse_id: 1, quantity: 10000, seuil: 2000 }, // Brique
        { product_id: 4, warehouse_id: 2, quantity: 50, seuil: 10 },    // Gravier
        { product_id: 5, warehouse_id: 2, quantity: 80, seuil: 15 },    // Sable
        { product_id: 6, warehouse_id: 1, quantity: 3000, seuil: 500 }  // Parpaing
    ];

    const stmt = db.prepare(`INSERT INTO stock (product_id, warehouse_id, quantity, seuil_critique) VALUES (?, ?, ?, ?)`);
    for (const s of stocks) {
        await new Promise((resolve, reject) => {
            stmt.run(s.product_id, s.warehouse_id, s.quantity, s.seuil, (err) => {
                if (err) reject(err);
                else resolve();
            });
        });
    }
    stmt.finalize();
    console.log(`✅ Entrepôts et stocks initiaux créés.`);
}

module.exports = { db, runAsync, getAsync, allAsync, initDatabase };