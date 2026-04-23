const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'products.db');
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
  console.log('🔄 Initialisation de la base produits...');

  await runAsync(`
    CREATE TABLE IF NOT EXISTS products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      description TEXT,
      categorie TEXT CHECK(categorie IN ('ciment', 'fer', 'brique', 'granulat', 'autre')) NOT NULL,
      unite TEXT NOT NULL DEFAULT 'unité',
      prix_unitaire REAL NOT NULL,
      image_url TEXT,
      actif BOOLEAN DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await runAsync(`CREATE INDEX IF NOT EXISTS idx_products_categorie ON products(categorie)`);
  await runAsync(`CREATE INDEX IF NOT EXISTS idx_products_actif ON products(actif)`);

  // Trigger
  db.exec(`
    CREATE TRIGGER IF NOT EXISTS update_products_timestamp 
    AFTER UPDATE ON products
    BEGIN
      UPDATE products SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
    END;
  `);

  const row = await getAsync(`SELECT COUNT(*) as count FROM products`);
  if (row.count === 0) {
    console.log('🌱 Insertion des produits de test...');
    await seedDatabase();
  } else {
    console.log(`✅ Base produits déjà initialisée avec ${row.count} produit(s).`);
  }
}

async function seedDatabase() {
  const products = [
    { nom: 'Ciment Portland 50kg', description: 'Ciment de haute qualité pour construction', categorie: 'ciment', unite: 'sac', prix_unitaire: 6500, image_url: 'https://fr.freepik.com/photos-gratuite/mode-vie-personnes-respectueuses-environnement_19118444.htm#fromView=search&page=2&position=12&uuid=a242234c-0f98-4e5d-83c2-1c442e552cbc&query=Ciment+Portland+50kg' },
    { nom: 'Fer à béton 10mm', description: 'Fer à béton laminé à chaud, longueur 12m', categorie: 'fer', unite: 'barre', prix_unitaire: 4500, image_url: 'https://fr.freepik.com/photos-gratuite/groupe-tiges-acier-serrees-par-chaine-soulevees-chantier-construction_4550490.htm#fromView=search&page=1&position=1&uuid=3495d641-03b3-45c0-859e-37d9c7d503de&query=Fer+%C3%A0+b%C3%A9ton+lamin%C3%A9+%C3%A0+chaud' },
    { nom: 'Brique rouge', description: 'Brique pleine en terre cuite', categorie: 'brique', unite: 'pièce', prix_unitaire: 150, image_url: 'https://fr.freepik.com/photos-gratuite/mur-briques-mal-placees_1006596.htm#fromView=search&page=1&position=5&uuid=31597e9b-4245-4cdc-934e-c53c77746bc5&query=Brique+pleine+en+terre+cuite' },
    { nom: 'Gravier 5/15', description: 'Gravier concassé pour béton', categorie: 'granulat', unite: 'tonne', prix_unitaire: 25000, image_url: 'https://fr.freepik.com/photos-gratuite/photo-du-motif-texture-pierre_225749277.htm#fromView=search&page=1&position=4&uuid=91746517-de1a-449a-b85f-030b21d171fc&query=Gravier+concass%C3%A9+pour+b%C3%A9ton' },
    { nom: 'Sable fin', description: 'Sable de rivière tamisé', categorie: 'granulat', unite: 'tonne', prix_unitaire: 18000, image_url: 'https://fr.freepik.com/photos-gratuite/koyashskoe-lac-sale-rose-crimee_1284838.htm#fromView=search&page=1&position=4&uuid=d36e2741-e363-4345-bb94-260387ec79eb&query=Sable+de+rivi%C3%A8re+tamis%C3%A9' },
    { nom: 'Parpaing creux 20x20x40', description: 'Bloc de béton standard', categorie: 'brique', unite: 'pièce', prix_unitaire: 350, image_url: 'https://fr.freepik.com/photos-gratuite/ouvrier-construit-mur-blocs-ciment-pour-nouvelle-maison_27572676.htm#fromView=search&page=1&position=0&uuid=97ca148c-a703-450e-abc4-e63a9ac6e08b&query=Bloc+de+b%C3%A9ton+standard' }
  ];

  const stmt = db.prepare(`INSERT INTO products (nom, description, categorie, unite, prix_unitaire, image_url) VALUES (?, ?, ?, ?, ?, ?)`);
  for (const p of products) {
    await new Promise((resolve, reject) => {
      stmt.run(p.nom, p.description, p.categorie, p.unite, p.prix_unitaire, p.image_url, (err) => {
        if (err) reject(err);
        else resolve();
      });
    });
  }
  stmt.finalize();
  console.log(`✅ ${products.length} produits créés.`);
}

module.exports = { db, runAsync, getAsync, allAsync, initDatabase };