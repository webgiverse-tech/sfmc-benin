const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'production.db');
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
    console.log('🔄 Initialisation de la base de données production...');

    // Table des machines
    await runAsync(`
    CREATE TABLE IF NOT EXISTS machines (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      statut TEXT CHECK(statut IN ('available', 'in_use', 'maintenance')) DEFAULT 'available',
      capacite_jour REAL DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

    // Table des ordres de production
    await runAsync(`
    CREATE TABLE IF NOT EXISTS production_orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER NOT NULL,
      quantity_target REAL NOT NULL,
      quantity_produced REAL DEFAULT 0,
      statut TEXT CHECK(statut IN ('planned', 'in_progress', 'completed', 'cancelled')) DEFAULT 'planned',
      date_debut DATE,
      date_fin DATE,
      machine_id INTEGER,
      notes TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (machine_id) REFERENCES machines(id)
    )
  `);

    // Index pour recherche rapide
    await runAsync(`CREATE INDEX IF NOT EXISTS idx_po_statut ON production_orders(statut)`);

    // Trigger pour mise à jour du statut de la machine quand utilisée
    db.exec(`
    CREATE TRIGGER IF NOT EXISTS update_machine_status_on_po
    AFTER UPDATE ON production_orders
    WHEN NEW.statut = 'in_progress' AND NEW.machine_id IS NOT NULL
    BEGIN
      UPDATE machines SET statut = 'in_use' WHERE id = NEW.machine_id;
    END;
  `);

    db.exec(`
    CREATE TRIGGER IF NOT EXISTS release_machine_on_completion
    AFTER UPDATE ON production_orders
    WHEN NEW.statut = 'completed' AND OLD.statut != 'completed' AND NEW.machine_id IS NOT NULL
    BEGIN
      UPDATE machines SET statut = 'available' WHERE id = NEW.machine_id;
    END;
  `);

    const machineCount = await getAsync(`SELECT COUNT(*) as count FROM machines`);
    if (machineCount.count === 0) {
        console.log('🌱 Insertion des données de test...');
        await seedDatabase();
    } else {
        console.log(`✅ Base production déjà initialisée.`);
    }
}

async function seedDatabase() {
    // Machines
    const machines = [
        { nom: 'Presse à briques', statut: 'available', capacite_jour: 5000 },
        { nom: 'Laminoir à fer', statut: 'available', capacite_jour: 2000 },
        { nom: 'Concasseur', statut: 'maintenance', capacite_jour: 100 }
    ];
    const machineIds = [];
    for (const m of machines) {
        const res = await runAsync(`INSERT INTO machines (nom, statut, capacite_jour) VALUES (?, ?, ?)`, [m.nom, m.statut, m.capacite_jour]);
        machineIds.push(res.lastID);
    }

    // Ordres de production de test
    const orders = [
        { product_id: 1, quantity_target: 1000, quantity_produced: 0, statut: 'planned', date_debut: '2026-05-01', machine_id: machineIds[0] },
        { product_id: 2, quantity_target: 500, quantity_produced: 200, statut: 'in_progress', date_debut: '2026-04-20', machine_id: machineIds[1] },
        { product_id: 3, quantity_target: 2000, quantity_produced: 2000, statut: 'completed', date_debut: '2026-04-10', date_fin: '2026-04-15', machine_id: machineIds[0] }
    ];

    for (const o of orders) {
        await runAsync(
            `INSERT INTO production_orders (product_id, quantity_target, quantity_produced, statut, date_debut, date_fin, machine_id) VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [o.product_id, o.quantity_target, o.quantity_produced, o.statut, o.date_debut, o.date_fin || null, o.machine_id]
        );
    }

    console.log(`✅ Machines et ordres de production de test créés.`);
}

module.exports = { db, runAsync, getAsync, allAsync, initDatabase };