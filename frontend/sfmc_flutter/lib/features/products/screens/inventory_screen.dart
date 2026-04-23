import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/widgets/loading_widget.dart';
import 'package:sfmc_flutter/features/inventory/providers/inventory_provider.dart';
import 'package:sfmc_flutter/features/inventory/widgets/stock_table.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Stocks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigation vers historique mouvements
            },
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Chargement des stocks...');
          }

          return RefreshIndicator(
            onRefresh: provider.fetchInventory,
            child: Column(
              children: [
                // Résumé des stocks
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total produits',
                          provider.stocks.length.toString(),
                          Icons.inventory,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryCard(
                          'Quantité totale',
                          provider.totalQuantity.toStringAsFixed(0),
                          Icons.storage,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryCard(
                          'Alertes',
                          provider.alertsCount.toString(),
                          Icons.warning,
                          color: provider.alertsCount > 0
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: StockTable(stocks: provider.stocks)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ouvrir formulaire mouvement stock
        },
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: color ?? Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12)),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
