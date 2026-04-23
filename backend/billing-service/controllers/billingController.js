const { runAsync, getAsync, allAsync } = require('../database/db');
const { getOrderById } = require('../services/orderClient');
const { getUserById } = require('../services/userClient');

// GET /billing/factures – liste des factures avec filtres
exports.getAllFactures = async (req, res, next) => {
    try {
        const { statut, client_id, date_debut, date_fin } = req.query;
        let query = 'SELECT * FROM factures WHERE 1=1';
        const params = [];

        if (statut) { query += ' AND statut = ?'; params.push(statut); }
        if (client_id) { query += ' AND client_id = ?'; params.push(client_id); }
        if (date_debut) { query += ' AND date_emission >= ?'; params.push(date_debut); }
        if (date_fin) { query += ' AND date_emission <= ?'; params.push(date_fin + ' 23:59:59'); }

        query += ' ORDER BY date_emission DESC';
        const factures = await allAsync(query, params);

        // Enrichir avec les infos client
        for (let f of factures) {
            try {
                const user = await getUserById(f.client_id);
                f.client_nom = `${user.nom} ${user.prenom}`;
                f.client_email = user.email;
            } catch (e) {
                f.client_nom = `Client #${f.client_id}`;
            }
            // Récupérer la somme des paiements
            const totalPaye = await getAsync(`SELECT COALESCE(SUM(montant), 0) as total FROM paiements WHERE facture_id = ?`, [f.id]);
            f.montant_paye = totalPaye.total;
            f.reste_a_payer = f.montant_total - f.montant_paye;
        }

        res.json({ success: true, count: factures.length, data: factures });
    } catch (error) {
        next(error);
    }
};

// GET /billing/factures/:id – détail d'une facture
exports.getFactureById = async (req, res, next) => {
    try {
        const facture = await getAsync('SELECT * FROM factures WHERE id = ?', [req.params.id]);
        if (!facture) return res.status(404).json({ success: false, error: 'Facture non trouvée' });

        // Infos client
        const user = await getUserById(facture.client_id);
        facture.client_nom = `${user.nom} ${user.prenom}`;
        facture.client_email = user.email;
        facture.client_telephone = user.telephone;
        facture.client_adresse = user.adresse;

        // Infos commande
        try {
            const order = await getOrderById(facture.order_id);
            facture.order = order;
        } catch (e) {
            facture.order = { id: facture.order_id, error: 'Commande non disponible' };
        }

        // Paiements associés
        facture.paiements = await allAsync('SELECT * FROM paiements WHERE facture_id = ? ORDER BY date DESC', [facture.id]);
        const totalPaye = facture.paiements.reduce((sum, p) => sum + p.montant, 0);
        facture.montant_paye = totalPaye;
        facture.reste_a_payer = facture.montant_total - totalPaye;

        res.json({ success: true, data: facture });
    } catch (error) {
        next(error);
    }
};

// POST /billing/factures – générer une facture à partir d'une commande
exports.createFactureFromOrder = async (req, res, next) => {
    try {
        const { order_id, date_echeance, notes } = req.body;
        if (!order_id) return res.status(400).json({ success: false, error: 'order_id requis' });

        // Vérifier si une facture existe déjà pour cette commande
        const existing = await getAsync('SELECT id FROM factures WHERE order_id = ?', [order_id]);
        if (existing) return res.status(409).json({ success: false, error: 'Une facture existe déjà pour cette commande' });

        // Récupérer la commande depuis Order Service
        const order = await getOrderById(order_id);
        if (!order) return res.status(404).json({ success: false, error: 'Commande non trouvée' });

        // Créer la facture
        const result = await runAsync(
            `INSERT INTO factures (order_id, client_id, montant_total, date_echeance, notes) VALUES (?, ?, ?, ?, ?)`,
            [order_id, order.client_id, order.total, date_echeance || null, notes || null]
        );

        const facture = await getAsync('SELECT * FROM factures WHERE id = ?', [result.lastID]);
        res.status(201).json({ success: true, message: 'Facture générée', data: facture });
    } catch (error) {
        next(error);
    }
};

// PUT /billing/factures/:id/paiement – enregistrer un paiement
exports.addPaiement = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { montant, mode, reference } = req.body;

        if (!montant || !mode) {
            return res.status(400).json({ success: false, error: 'montant et mode requis' });
        }
        const validModes = ['especes', 'virement', 'cheque', 'mobile_money'];
        if (!validModes.includes(mode)) {
            return res.status(400).json({ success: false, error: `Mode invalide. Valeurs acceptées : ${validModes.join(', ')}` });
        }

        const facture = await getAsync('SELECT * FROM factures WHERE id = ?', [id]);
        if (!facture) return res.status(404).json({ success: false, error: 'Facture non trouvée' });

        // Vérifier que le montant ne dépasse pas le reste à payer
        const totalPayeRow = await getAsync(`SELECT COALESCE(SUM(montant), 0) as total FROM paiements WHERE facture_id = ?`, [id]);
        const reste = facture.montant_total - totalPayeRow.total;
        if (montant > reste) {
            return res.status(400).json({ success: false, error: `Le montant dépasse le reste à payer (${reste})` });
        }

        const result = await runAsync(
            `INSERT INTO paiements (facture_id, montant, mode, reference) VALUES (?, ?, ?, ?)`,
            [id, montant, mode, reference || null]
        );

        const paiement = await getAsync('SELECT * FROM paiements WHERE id = ?', [result.lastID]);
        const factureUpdated = await getAsync('SELECT * FROM factures WHERE id = ?', [id]);
        const totalPaye = await getAsync(`SELECT COALESCE(SUM(montant), 0) as total FROM paiements WHERE facture_id = ?`, [id]);
        factureUpdated.montant_paye = totalPaye.total;
        factureUpdated.reste_a_payer = factureUpdated.montant_total - totalPaye.total;

        res.status(201).json({ success: true, message: 'Paiement enregistré', paiement, facture: factureUpdated });
    } catch (error) {
        next(error);
    }
};

// GET /billing/stats – statistiques financières
exports.getStats = async (req, res, next) => {
    try {
        const stats = await allAsync(`
      SELECT 
        COUNT(*) as total_factures,
        SUM(montant_total) as total_facture,
        SUM(CASE WHEN statut = 'paid' THEN montant_total ELSE 0 END) as total_paye,
        SUM(CASE WHEN statut = 'unpaid' THEN montant_total ELSE 0 END) as total_impaye,
        SUM(CASE WHEN statut = 'partial' THEN montant_total ELSE 0 END) as total_partiel
      FROM factures
    `);

        const paiements = await getAsync(`SELECT COALESCE(SUM(montant), 0) as total_paiements FROM paiements`);

        res.json({
            success: true,
            data: {
                total_factures: stats[0].total_factures,
                montant_total_facture: stats[0].total_facture || 0,
                montant_paye: stats[0].total_paye || 0,
                montant_impaye: stats[0].total_impaye || 0,
                montant_partiel: stats[0].total_partiel || 0,
                total_paiements_enregistres: paiements.total_paiements || 0
            }
        });
    } catch (error) {
        next(error);
    }
};