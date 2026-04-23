import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/widgets/data_table_widget.dart';
import 'package:sfmc_flutter/features/inventory/models/stock_model.dart';

class StockTable extends StatelessWidget {
  final List<StockItem> stocks;

  const StockTable({super.key, required this.stocks});

  @override
  Widget build(BuildContext context) {
    final columns = ['Produit', 'Entrepôt', 'Quantité', 'Seuil', 'Statut'];

    final rows = stocks.map((stock) {
      final isLow = stock.quantity <= stock.seuilCritique;
      return DataRow(
        cells: [
          DataCell(Text(stock.productName ?? 'Produit #${stock.productId}')),
          DataCell(
            Text(stock.warehouseName ?? 'Entrepôt #${stock.warehouseId}'),
          ),
          DataCell(Text(stock.quantity.toStringAsFixed(0))),
          DataCell(Text(stock.seuilCritique.toStringAsFixed(0))),
          DataCell(_buildStatusChip(stock, isLow)),
        ],
      );
    }).toList();

    return AppDataTable(columns: columns, rows: rows);
  }

  Widget _buildStatusChip(StockItem stock, bool isLow) {
    Color color;
    String text;
    if (isLow) {
      color = AppColors.danger;
      text = 'Critique';
    } else if (stock.quantity <= stock.seuilCritique * 1.5) {
      color = AppColors.warning;
      text = 'Alerte';
    } else {
      color = AppColors.success;
      text = 'OK';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
