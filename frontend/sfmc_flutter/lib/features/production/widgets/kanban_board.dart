import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/features/production/models/production_model.dart';

class KanbanBoard extends StatelessWidget {
  final List<ProductionOrder> orders;

  const KanbanBoard({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final planned = orders.where((o) => o.statut == 'planned').toList();
    final inProgress = orders.where((o) => o.statut == 'in_progress').toList();
    final completed = orders.where((o) => o.statut == 'completed').toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColumn('Planifiées', planned, AppColors.info, context),
                _buildColumn(
                  'En cours',
                  inProgress,
                  AppColors.warning,
                  context,
                ),
                _buildColumn(
                  'Terminées',
                  completed,
                  AppColors.success,
                  context,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColumn(
    String title,
    List<ProductionOrder> orders,
    Color color,
    BuildContext context,
  ) {
    return SizedBox(
      width: 300,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Chip(label: Text('${orders.length}')),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...orders.map((order) => _buildOrderCard(order, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(ProductionOrder order, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.productName ?? 'Produit #${order.productId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: order.quantityTarget > 0
                  ? order.quantityProduced / order.quantityTarget
                  : 0,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
            Text('${order.quantityProduced} / ${order.quantityTarget}'),
            if (order.machineName != null)
              Text('Machine: ${order.machineName}'),
          ],
        ),
      ),
    );
  }
}
