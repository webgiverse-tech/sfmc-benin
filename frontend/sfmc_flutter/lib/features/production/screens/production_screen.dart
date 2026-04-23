import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/widgets/loading_widget.dart';
import 'package:sfmc_flutter/features/production/providers/production_provider.dart';
import 'package:sfmc_flutter/features/production/widgets/kanban_board.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductionProvider>().fetchProductionOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de la Production'),
        actions: [
          IconButton(
            icon: const Icon(Icons.precision_manufacturing),
            onPressed: () {
              // Voir machines
            },
          ),
        ],
      ),
      body: Consumer<ProductionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Chargement...');
          }

          return RefreshIndicator(
            onRefresh: provider.fetchProductionOrders,
            child: KanbanBoard(orders: provider.orders),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Nouvel ordre de production
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
