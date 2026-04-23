const { runAsync, getAsync, allAsync } = require('../database/db');

exports.getAllProducts = async (req, res, next) => {
    try {
        const { categorie, actif, search } = req.query;
        let query = 'SELECT * FROM products WHERE 1=1';
        const params = [];

        if (categorie) { query += ' AND categorie = ?'; params.push(categorie); }
        if (actif !== undefined) { query += ' AND actif = ?'; params.push(actif === 'true' ? 1 : 0); }
        if (search) {
            query += ' AND (nom LIKE ? OR description LIKE ?)';
            const pattern = `%${search}%`;
            params.push(pattern, pattern);
        }
        query += ' ORDER BY categorie, nom';

        const products = await allAsync(query, params);
        res.json({ success: true, count: products.length, data: products });
    } catch (error) {
        next(error);
    }
};

exports.getProductById = async (req, res, next) => {
    try {
        const product = await getAsync('SELECT * FROM products WHERE id = ?', [req.params.id]);
        if (!product) return res.status(404).json({ success: false, error: 'Produit non trouvé' });
        res.json({ success: true, data: product });
    } catch (error) {
        next(error);
    }
};

exports.createProduct = async (req, res, next) => {
    try {
        const { nom, description, categorie, unite, prix_unitaire, image_url, actif } = req.body;
        if (!nom || !categorie || !unite || prix_unitaire === undefined) {
            return res.status(400).json({ success: false, error: 'Champs obligatoires manquants' });
        }

        const result = await runAsync(
            `INSERT INTO products (nom, description, categorie, unite, prix_unitaire, image_url, actif) VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [nom, description, categorie, unite, prix_unitaire, image_url || null, actif !== undefined ? (actif ? 1 : 0) : 1]
        );
        const newProduct = await getAsync('SELECT * FROM products WHERE id = ?', [result.lastID]);
        res.status(201).json({ success: true, message: 'Produit créé', data: newProduct });
    } catch (error) {
        next(error);
    }
};

exports.updateProduct = async (req, res, next) => {
    try {
        const { id } = req.params;
        const existing = await getAsync('SELECT id FROM products WHERE id = ?', [id]);
        if (!existing) return res.status(404).json({ success: false, error: 'Produit non trouvé' });

        const { nom, description, categorie, unite, prix_unitaire, image_url, actif } = req.body;
        await runAsync(
            `UPDATE products SET
        nom = COALESCE(?, nom), description = COALESCE(?, description), categorie = COALESCE(?, categorie),
        unite = COALESCE(?, unite), prix_unitaire = COALESCE(?, prix_unitaire), image_url = COALESCE(?, image_url),
        actif = COALESCE(?, actif), updated_at = CURRENT_TIMESTAMP
      WHERE id = ?`,
            [nom, description, categorie, unite, prix_unitaire, image_url, actif !== undefined ? (actif ? 1 : 0) : null, id]
        );

        const updated = await getAsync('SELECT * FROM products WHERE id = ?', [id]);
        res.json({ success: true, message: 'Produit mis à jour', data: updated });
    } catch (error) {
        next(error);
    }
};

exports.deleteProduct = async (req, res, next) => {
    try {
        const { id } = req.params;
        const existing = await getAsync('SELECT id FROM products WHERE id = ?', [id]);
        if (!existing) return res.status(404).json({ success: false, error: 'Produit non trouvé' });

        await runAsync('DELETE FROM products WHERE id = ?', [id]);
        res.json({ success: true, message: 'Produit supprimé' });
    } catch (error) {
        next(error);
    }
};