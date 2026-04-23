import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';

class AppDataTable extends StatelessWidget {
  final List<String> columns;
  final List<DataRow> rows;
  final bool sortColumnAscending;
  final int? sortColumnIndex;
  final Function(int, bool)? onSort;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnAscending = true,
    this.sortColumnIndex,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: columns.length * 150.0,
          columns: columns.asMap().entries.map((entry) {
            return DataColumn2(
              label: Text(entry.value),
              onSort: onSort != null
                  ? (columnIndex, ascending) => onSort!(columnIndex, ascending)
                  : null,
              size: ColumnSize.L,
            );
          }).toList(),
          rows: rows,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortColumnAscending,
        ),
      ),
    );
  }
}
