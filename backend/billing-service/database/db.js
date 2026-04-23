const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'billing.db');
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
    console.log('🔄 Initialisation de la base de données facturation...');

    // Table des factures
    await runAsync(`
    CREATE TABLE IF NOT EXISTS factures (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER UNIQUE NOT NULL,
      client_id INTEGER NOT NULL,
      montant_total REAL NOT NULL,
      statut TEXT CHECK(statut IN ('unpaid', 'partial', 'paid')) DEFAULT 'unpaid',
      date_emission DATETIME DEFAULT CURRENT_TIMESTAMP,
      date_echeance DATE,
      notes TEXT
    )
  `);

    // Table des paiements
    await runAsync(`
    CREATE TABLE IF NOT EXISTS paiements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      facture_id INTEGER NOT NULL,
      montant REAL NOT NULL,
      mode TEXT CHECK(mode IN ('especes', 'virement', 'cheque', 'mobile_money')) NOT NULL,
      date DATETIME DEFAULT CURRENT_TIMESTAMP,
      reference TEXT,
      FOREIGN KEY (facture_id) REFERENCES factures(id)
    )
  `);

    // Trigger pour mettre à jour le statut de la facture après paiement
    db.exec(`
    CREATE TRIGGER IF NOT EXISTS update_facture_statut_after_paiement
    AFTER INSERT ON paiements
    BEGIN
      UPDATE factures 
      SET statut = CASE 
        WHEN (SELECT COALESCE(SUM(montant), 0) FROM paiements WHERE facture_id = NEW.facture_id) >= montant_total THEN 'paid'
        WHEN (SELECT COALESCE(SUM(montant), 0) FROM paiements WHERE facture_id = NEW.facture_id) > 0 THEN 'partial'
        ELSE 'unpaid'
      END
      WHERE id = NEW.facture_id;
    END;
  `);

    const count = await getAsync(`SELECT COUNT(*) as count FROM factures`);
    if (count.count === 0) {
        console.log('🌱 Insertion des factures de test...');
        await seedDatabase();
    } else {
        console.log(`✅ Base facturation déjà initialisée avec ${count.count} facture(s).`);
    }
}

async function seedDatabase() {
    // Créer quelques factures de test basées sur les commandes existantes (order_id 1 à 5)
    const factures = [
        { order_id: 1, client_id: 3, montant_total: 65000, statut: 'unpaid', date_echeance: '2026-05-15' },
        { order_id: 2, client_id: 4, montant_total: 255000, statut: 'partial', date_echeance: '2026-05-10' },
        { order_id: 3, client_id: 3, montant_total: 50000, statut: 'paid', date_echeance: '2026-04-30' },
        { order_id: 4, client_id: 4, montant_total: 90000, statut: 'unpaid', date_echeance: '2026-05-20' }
    ];

    const paiements = [
        { facture_id: 2, montant: 100000, mode: 'virement', reference: 'VIR-001' },
        { facture_id: 3, montant: 50000, mode: 'especes', reference: null }
    ];

    for (const f of factures) {
        await runAsync(
            `INSERT INTO factures (order_id, client_id, montant_total, statut, date_echeance) VALUES (?, ?, ?, ?, ?)`,
            [f.order_id, f.client_id, f.montant_total, f.statut, f.date_echeance]
        );
    }

    for (const p of paiements) {
        await runAsync(
            `INSERT INTO paiements (facture_id, montant, mode, reference) VALUES (?, ?, ?, ?)`,
            [p.facture_id, p.montant, p.mode, p.reference]
        );
    }

    console.log(`✅ Factures et paiements de test créés.`);
}

module.exports = { db, runAsync, getAsync, allAsync, initDatabase };