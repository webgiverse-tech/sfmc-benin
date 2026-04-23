const inventoryClient = require('../services/inventoryClient');
const orderClient = require('../services/orderClient');
const productionClient = require('../services/productionClient');
const billingClient = require('../services/billingClient');
const userClient = require('../services/userClient');

// Helper pour filtrer par période (date début/fin)
function filterByDateRange(items, dateField, start, end) {
    if (!start && !end) return items;
    return items.filter(item => {
        const itemDate = new Date(item[dateField]);
        if (start && itemDate < new Date(start)) return false;
        if (end) {
            const endDate = new Date(end);
            endDate.setHours(23, 59, 59, 999);
            if (itemDate > endDate) return false;
        }
        return true;
    });
}

// GET /reporting/dashboard – KPIs globaux
exports.getDashboard = async (req, res, next) => {
    try {
        // Récupération parallèle des données nécessaires
        const [inventory, alerts, orders, productions, billingStats, users] = await Promise.all([
            inventoryClient.getFullInventory().catch(() => []),
            inventoryClient.getAlerts().catch(() => []),
            orderClient.getAllOrders().catch(() => []),
            productionClient.getAllProductionOrders().catch(() => []),
            billingClient.getStats().catch(() => ({})),
            userClient.getAllUsers().catch(() => [])
        ]);

        // Calculs KPI
        const totalStock = inventory.reduce((sum, s) => sum + (s.quantity || 0), 0);
        const pendingOrders = orders.filter(o => o.statut === 'pending' || o.statut === 'validated').length;
        const today = new Date().toISOString().split('T')[0];
        const productionsToday = productions.filter(p => p.date_debut === today).length;
        const lowStockCount = alerts.length;

        const dashboard = {
            kpis: {
                total_orders: orders.length,
                pending_orders: pendingOrders,
                total_stock_quantity: totalStock,
                low_stock_alerts: lowStockCount,
                productions_today: productionsToday,
                total_users: users.length,
                chiffre_affaires_total: billingStats.montant_total_facture || 0,
                chiffre_affaires_paye: billingStats.montant_paye || 0,
                impayes: billingStats.montant_impaye || 0
            },
            recent_orders: orders.slice(0, 5),
            stock_alerts: alerts.slice(0, 5)
        };

        res.json({ success: true, data: dashboard });
    } catch (error) {
        next(error);
    }
};

// GET /reporting/ventes – rapport ventes par période
exports.getSalesReport = async (req, res, next) => {
    try {
        const { start_date, end_date, group_by = 'day' } = req.query;
        const orders = await orderClient.getAllOrders().catch(() => []);
        const filtered = filterByDateRange(orders, 'date_commande', start_date, end_date);

        // Grouper par jour/semaine/mois
        const grouped = {};
        filtered.forEach(order => {
            const date = new Date(order.date_commande);
            let key;
            if (group_by === 'month') key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
            else if (group_by === 'week') {
                const week = getWeekNumber(date);
                key = `${date.getFullYear()}-W${week}`;
            } else key = date.toISOString().split('T')[0];

            if (!grouped[key]) grouped[key] = { period: key, count: 0, total: 0 };
            grouped[key].count++;
            grouped[key].total += order.total || 0;
        });

        const result = Object.values(grouped).sort((a, b) => a.period.localeCompare(b.period));
        res.json({ success: true, data: result });
    } catch (error) {
        next(error);
    }
};

// Helper pour numéro de semaine
function getWeekNumber(d) {
    const date = new Date(d);
    date.setHours(0, 0, 0, 0);
    date.setDate(date.getDate() + 3 - (date.getDay() + 6) % 7);
    const week1 = new Date(date.getFullYear(), 0, 4);
    return 1 + Math.round(((date - week1) / 86400000 - 3 + (week1.getDay() + 6) % 7) / 7);
}

// GET /reporting/stock – rapport stock
exports.getStockReport = async (req, res, next) => {
    try {
        const inventory = await inventoryClient.getFullInventory().catch(() => []);

        // Regrouper par produit
        const byProduct = {};
        inventory.forEach(item => {
            const pid = item.product_id;
            if (!byProduct[pid]) byProduct[pid] = { product_id: pid, product_name: item.product_name, total_quantity: 0, warehouses: [] };
            byProduct[pid].total_quantity += item.quantity;
            byProduct[pid].warehouses.push({ id: item.warehouse_id, name: item.warehouse_name, quantity: item.quantity });
        });

        // Statistiques
        const totalValue = inventory.reduce((sum, i) => sum + (i.quantity * (i.prix_unitaire || 0)), 0);
        const lowStock = inventory.filter(i => i.quantity <= i.seuil_critique);

        res.json({
            success: true,
            data: {
                total_products: Object.keys(byProduct).length,
                total_warehouses: [...new Set(inventory.map(i => i.warehouse_id))].length,
                total_stock_value: totalValue,
                low_stock_items: lowStock.length,
                details: Object.values(byProduct)
            }
        });
    } catch (error) {
        next(error);
    }
};

// GET /reporting/production – rapport production
exports.getProductionReport = async (req, res, next) => {
    try {
        const { start_date, end_date } = req.query;
        const productions = await productionClient.getAllProductionOrders().catch(() => []);
        const machines = await productionClient.getMachines().catch(() => []);
        const filtered = filterByDateRange(productions, 'date_debut', start_date, end_date);

        const completed = filtered.filter(p => p.statut === 'completed');
        const inProgress = filtered.filter(p => p.statut === 'in_progress');
        const planned = filtered.filter(p => p.statut === 'planned');

        const totalProduced = completed.reduce((sum, p) => sum + (p.quantity_produced || 0), 0);
        const efficiency = completed.length ? (completed.reduce((sum, p) => sum + (p.quantity_produced / p.quantity_target), 0) / completed.length) * 100 : 0;

        res.json({
            success: true,
            data: {
                summary: {
                    total_orders: filtered.length,
                    completed: completed.length,
                    in_progress: inProgress.length,
                    planned: planned.length,
                    total_quantity_produced: totalProduced,
                    average_efficiency: Math.round(efficiency)
                },
                machines: machines.map(m => ({
                    ...m,
                    current_production: productions.find(p => p.machine_id === m.id && p.statut === 'in_progress') || null
                })),
                recent_completed: completed.slice(0, 10)
            }
        });
    } catch (error) {
        next(error);
    }
};

// GET /reporting/finances – rapport financier
exports.getFinanceReport = async (req, res, next) => {
    try {
        const { start_date, end_date } = req.query;
        const factures = await billingClient.getAllFactures().catch(() => []);
        const stats = await billingClient.getStats().catch(() => ({}));
        const filtered = filterByDateRange(factures, 'date_emission', start_date, end_date);

        const totalFacture = filtered.reduce((sum, f) => sum + f.montant_total, 0);
        const totalPaye = filtered.reduce((sum, f) => sum + (f.montant_paye || 0), 0);
        const totalImpaye = totalFacture - totalPaye;

        // Évolution mensuelle
        const byMonth = {};
        filtered.forEach(f => {
            const month = f.date_emission.substring(0, 7);
            if (!byMonth[month]) byMonth[month] = { month, factures: 0, montant: 0, paye: 0 };
            byMonth[month].factures++;
            byMonth[month].montant += f.montant_total;
            byMonth[month].paye += f.montant_paye || 0;
        });

        res.json({
            success: true,
            data: {
                summary: {
                    total_factures: filtered.length,
                    montant_total: totalFacture,
                    montant_paye: totalPaye,
                    montant_impaye: totalImpaye,
                    taux_recouvrement: totalFacture ? (totalPaye / totalFacture) * 100 : 0
                },
                monthly_evolution: Object.values(byMonth).sort((a, b) => a.month.localeCompare(b.month)),
                global_stats: stats
            }
        });
    } catch (error) {
        next(error);
    }
};