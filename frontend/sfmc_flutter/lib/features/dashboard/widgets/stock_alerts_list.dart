import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';

class StockAlertsList extends StatelessWidget {
  const StockAlertsList({super.key});

  @override
  Widget build(BuildContext context) {
    // Données simulées
    final alerts = [
      {'product': 'Ciment Portland', 'stock': 80, 'seuil': 100},
      {'product': 'Fer à béton 10mm', 'stock': 400, 'seuil': 500},
      {'product': 'Gravier 5/15', 'stock': 8, 'seuil': 10},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: AppColors.danger),
                const SizedBox(width: 8),
                const Text(
                  'Alertes de stock',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text('${alerts.length}'),
                  backgroundColor: AppColors.danger.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...alerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert['product'] as String),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value:
                                (alert['stock'] as int) /
                                (alert['seuil'] as int),
                            backgroundColor: Colors.grey[200],
                            color: AppColors.danger,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${alert['stock']} / ${alert['seuil']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            TextButton(
              onPressed: () {},
              child: const Text('Voir tous les stocks critiques'),
            ),
          ],
        ),
      ),
    );
  }
}
