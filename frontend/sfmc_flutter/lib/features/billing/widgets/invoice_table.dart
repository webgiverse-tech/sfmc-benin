import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/utils/formatters.dart';
import 'package:sfmc_flutter/core/widgets/data_table_widget.dart';
import 'package:sfmc_flutter/features/billing/models/invoice_model.dart';

class InvoiceTable extends StatelessWidget {
  final List<Facture> factures;

  const InvoiceTable({super.key, required this.factures});

  @override
  Widget build(BuildContext context) {
    final columns = [
      'N°',
      'Client',
      'Date',
      'Total',
      'Payé',
      'Reste',
      'Statut',
    ];

    final rows = factures.map((facture) {
      return DataRow(
        cells: [
          DataCell(Text('#${facture.id}')),
          DataCell(Text(facture.clientNom ?? 'Client #${facture.clientId}')),
          DataCell(Text(Formatters.formatDate(facture.dateEmission))),
          DataCell(Text(Formatters.formatCurrency(facture.montantTotal))),
          DataCell(Text(Formatters.formatCurrency(facture.montantPaye))),
          DataCell(
            Text(
              Formatters.formatCurrency(facture.resteAPayer),
              style: TextStyle(
                color: facture.resteAPayer > 0
                    ? AppColors.danger
                    : AppColors.success,
              ),
            ),
          ),
          DataCell(_buildStatusChip(facture.statut)),
        ],
      );
    }).toList();

    return AppDataTable(columns: columns, rows: rows);
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'paid':
        color = AppColors.success;
        label = 'Payée';
        break;
      case 'partial':
        color = AppColors.warning;
        label = 'Partiel';
        break;
      case 'unpaid':
        color = AppColors.danger;
        label = 'Impayée';
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
