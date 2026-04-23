const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'orders.db');
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
    console.log('🔄 Initialisation de la base de données commandes...');

    // Table des commandes
    await runAsync(`
    CREATE TABLE IF NOT EXISTS orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      client_id INTEGER NOT NULL,
      statut TEXT CHECK(statut IN ('pending', 'validated', 'shipped', 'delivered', 'cancelled')) DEFAULT 'pending',
      date_commande DATETIME DEFAULT CURRENT_TIMESTAMP,
      date_livraison_prevue DATE,
      total REAL DEFAULT 0,
      notes TEXT
    )
  `);

    // Table des lignes de commande
    await runAsync(`
    CREATE TABLE IF NOT EXISTS order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL,
      quantity REAL NOT NULL,
      prix_unitaire REAL NOT NULL,
      FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
    )
  `);

    // Trigger pour recalculer le total après insertion/suppression d'items
    db.exec(`
    CREATE TRIGGER IF NOT EXISTS update_order_total_after_insert
    AFTER INSERT ON order_items
    BEGIN
      UPDATE orders SET total = (
        SELECT COALESCE(SUM(quantity * prix_unitaire), 0) FROM order_items WHERE order_id = NEW.order_id
      ) WHERE id = NEW.order_id;
    END;
  `);

    db.exec(`
    CREATE TRIGGER IF NOT EXISTS update_order_total_after_delete
    AFTER DELETE ON order_items
    BEGIN
      UPDATE orders SET total = (
        SELECT COALESCE(SUM(quantity * prix_unitaire), 0) FROM order_items WHERE order_id = OLD.order_id
      ) WHERE id = OLD.order_id;
    END;
  `);

    const count = await getAsync(`SELECT COUNT(*) as count FROM orders`);
    if (count.count === 0) {
        console.log('🌱 Insertion des commandes de test...');
        await seedDatabase();
    } else {
        console.log(`✅ Base commandes déjà initialisée avec ${count.count} commande(s).`);
    }
}

async function seedDatabase() {
    // Créer quelques commandes de test avec items
    const orders = [
        { client_id: 3, statut: 'pending', date_livraison_prevue: '2026-05-01' },
        { client_id: 4, statut: 'validated', date_livraison_prevue: '2026-04-28' },
        { client_id: 3, statut: 'shipped', date_livraison_prevue: '2026-04-25' },
        { client_id: 4, statut: 'delivered', date_livraison_prevue: '2026-04-20' },
        { client_id: 3, statut: 'cancelled', date_livraison_prevue: '2026-04-30' }
    ];

    const itemsData = [
        { order_idx: 0, items: [{ product_id: 1, quantity: 10, prix_unitaire: 6500 }] },
        { order_idx: 1, items: [{ product_id: 2, quantity: 50, prix_unitaire: 4500 }, { product_id: 3, quantity: 200, prix_unitaire: 150 }] },
        { order_idx: 2, items: [{ product_id: 4, quantity: 2, prix_unitaire: 25000 }] },
        { order_idx: 3, items: [{ product_id: 5, quantity: 5, prix_unitaire: 18000 }] },
        { order_idx: 4, items: [{ product_id: 6, quantity: 100, prix_unitaire: 350 }] }
    ];

    for (let i = 0; i < orders.length; i++) {
        const o = orders[i];
        const result = await runAsync(
            `INSERT INTO orders (client_id, statut, date_livraison_prevue) VALUES (?, ?, ?)`,
            [o.client_id, o.statut, o.date_livraison_prevue]
        );
        const orderId = result.lastID;
        const itemsForOrder = itemsData.find(d => d.order_idx === i)?.items || [];
        for (const item of itemsForOrder) {
            await runAsync(
                `INSERT INTO order_items (order_id, product_id, quantity, prix_unitaire) VALUES (?, ?, ?, ?)`,
                [orderId, item.product_id, item.quantity, item.prix_unitaire]
            );
        }
    }
    console.log(`✅ ${orders.length} commandes de test créées.`);
}

module.exports = { db, runAsync, getAsync, allAsync, initDatabase };