import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';

class SalesChart extends StatelessWidget {
  final List<dynamic> data;

  const SalesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Aucune donnée'));
    }

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['total'].toDouble());
    }).toList();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Évolution des ventes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < data.length) {
                            return Text(data[value.toInt()]['period']);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
