import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/widgets/stat_card.dart';

class KpiSummary extends StatelessWidget {
  final Map<String, dynamic> data;

  const KpiSummary({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: data.entries.map((entry) {
        return Card(
          child: ListTile(
            title: Text(entry.key),
            trailing: Text(entry.value.toString()),
          ),
        );
      }).toList(),
    );
  }
}
