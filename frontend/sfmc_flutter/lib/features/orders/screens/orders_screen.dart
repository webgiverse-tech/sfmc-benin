import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/widgets/loading_widget.dart';
import 'package:sfmc_flutter/features/orders/providers/order_provider.dart';
import 'package:sfmc_flutter/features/orders/widgets/order_table.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Commandes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Chargement des commandes...');
          }

          return RefreshIndicator(
            onRefresh: provider.fetchOrders,
            child: Column(
              children: [
                // Filtres rapides par statut
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      _buildFilterChip('Toutes', null, provider),
                      _buildFilterChip('En attente', 'pending', provider),
                      _buildFilterChip('Validées', 'validated', provider),
                      _buildFilterChip('Expédiées', 'shipped', provider),
                      _buildFilterChip('Livrées', 'delivered', provider),
                      _buildFilterChip('Annulées', 'cancelled', provider),
                    ],
                  ),
                ),
                Expanded(child: OrderTable(orders: provider.filteredOrders)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Créer nouvelle commande
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, OrderProvider provider) {
    final isSelected = provider.filterStatus == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => provider.setFilterStatus(value),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Implémenter filtre avancé
  }
}
