import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/utils/formatters.dart';
import 'package:sfmc_flutter/core/widgets/data_table_widget.dart';
import 'package:sfmc_flutter/features/orders/models/order_model.dart';

class OrderTable extends StatelessWidget {
  final List<Order> orders;

  const OrderTable({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final columns = ['N°', 'Client', 'Date', 'Livraison', 'Total', 'Statut'];

    final rows = orders.map((order) {
      return DataRow(
        cells: [
          DataCell(Text('#${order.id}')),
          DataCell(Text('Client #${order.clientId}')),
          DataCell(Text(Formatters.formatDate(order.dateCommande))),
          DataCell(
            Text(
              order.dateLivraisonPrevue != null
                  ? Formatters.formatDate(order.dateLivraisonPrevue!)
                  : '-',
            ),
          ),
          DataCell(Text(Formatters.formatCurrency(order.total))),
          DataCell(_buildStatusChip(order.statut)),
        ],
      );
    }).toList();

    return AppDataTable(columns: columns, rows: rows);
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'En attente';
        break;
      case 'validated':
        color = AppColors.info;
        label = 'Validée';
        break;
      case 'shipped':
        color = AppColors.primary;
        label = 'Expédiée';
        break;
      case 'delivered':
        color = AppColors.success;
        label = 'Livrée';
        break;
      case 'cancelled':
        color = AppColors.danger;
        label = 'Annulée';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
