import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/widgets/data_table_widget.dart';

class RecentOrdersTable extends StatelessWidget {
  const RecentOrdersTable({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple de données - remplacer par Provider
    final columns = ['ID', 'Client', 'Date', 'Total', 'Statut'];

    final rows =
        [
              ['#1001', 'Client 1', '15/04/2026', '65,000 FCFA', 'En attente'],
              ['#1002', 'Client 2', '14/04/2026', '255,000 FCFA', 'Validée'],
              ['#1003', 'Client 3', '13/04/2026', '50,000 FCFA', 'Expédiée'],
              ['#1004', 'Client 4', '12/04/2026', '90,000 FCFA', 'Livrée'],
              ['#1005', 'Client 5', '11/04/2026', '35,000 FCFA', 'Annulée'],
            ]
            .map(
              (row) => DataRow(
                cells: [
                  DataCell(Text(row[0])),
                  DataCell(Text(row[1])),
                  DataCell(Text(row[2])),
                  DataCell(Text(row[3])),
                  DataCell(_buildStatusChip(row[4])),
                ],
              ),
            )
            .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Commandes récentes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('Voir tout')),
              ],
            ),
            const SizedBox(height: 8),
            AppDataTable(columns: columns, rows: rows),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'en attente':
        color = AppColors.warning;
        break;
      case 'validée':
        color = AppColors.info;
        break;
      case 'expédiée':
        color = AppColors.primary;
        break;
      case 'livrée':
        color = AppColors.success;
        break;
      case 'annulée':
        color = AppColors.danger;
        break;
      default:
        color = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
