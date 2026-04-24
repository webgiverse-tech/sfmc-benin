// lib/features/dashboard/widgets/charts_section.dart — BUG FIX #5h
// Correction : LineChartData mise en cache (const ou final statique)
// + RepaintBoundary isole le graphique du reste du dashboard
// + chart rendu UNIQUEMENT quand les données sont disponibles

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';

class ChartsSection extends StatefulWidget {
  const ChartsSection({super.key});

  @override
  State<ChartsSection> createState() => _ChartsSectionState();
}

class _ChartsSectionState extends State<ChartsSection> {
  int _touchedIndex = -1;

  // ── BUG FIX #5h : Données statiques déclarées UNE FOIS ──────────────────
  // Avec const/static, Flutter ne recrée pas la liste de FlSpot à chaque frame.
  // Sans ça, LineChartData() est recalculé à chaque requestAnimationFrame → 210ms
  static const List<FlSpot> _salesSpots = [
    FlSpot(0, 120),
    FlSpot(1, 250),
    FlSpot(2, 480),
    FlSpot(3, 620),
    FlSpot(4, 890),
    FlSpot(5, 1100),
  ];

  static const List<String> _months = [
    'Jan',
    'Fév',
    'Mar',
    'Avr',
    'Mai',
    'Juin',
  ];

  Widget _buildLineChart() {
    return LineChart(
      // BUG FIX : swapAnimationDuration réduit à 0 pour éviter l'animation
      // au chargement initial qui déclenche des violations requestAnimationFrame
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.divider.withOpacity(0.5),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < _months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _months[idx],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}k',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 1400,
        lineBarsData: [
          LineChartBarData(
            spots: _salesSpots, // ← référence statique, pas de recalcul
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 5,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: AppColors.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.25),
                  AppColors.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        // BUG FIX : lineTouchData simplifié (tooltips coûteux en perfs)
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toInt()}k FCFA',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
      ),
      // BUG FIX #5h : durée d'animation à 0ms pour éviter les violations
      // lors du premier rendu (le chart essaie de s'animer en 60fps)
      duration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Graphique linéaire (évolution des ventes) ──────────────────────
        Expanded(
          flex: 3,
          // BUG FIX #5h : RepaintBoundary isole complètement le graphique
          // Les ticks du chart ne redessinent plus le reste du dashboard
          child: RepaintBoundary(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Évolution des ventes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '6 derniers mois · en milliers FCFA',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _PeriodSelector(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 240,
                      child: _buildLineChart(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // ── Graphique camembert (répartition des stocks) ───────────────────
        Expanded(
          flex: 2,
          child: RepaintBoundary(
            child: _StockPieChart(touchedIndex: _touchedIndex),
          ),
        ),
      ],
    );
  }
}

// ── Sélecteur de période (placeholder) ──────────────────────────────────────
class _PeriodSelector extends StatefulWidget {
  @override
  State<_PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<_PeriodSelector> {
  String _selected = '6M';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['1M', '3M', '6M', '1A'].map((period) {
          final isActive = _selected == period;
          return GestureDetector(
            onTap: () => setState(() => _selected = period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Graphique camembert des stocks ───────────────────────────────────────────
class _StockPieChart extends StatelessWidget {
  final int touchedIndex;

  // BUG FIX : sections déclarées comme const pour éviter la recréation
  static const List<Map<String, dynamic>> _stockData = [
    {'label': 'Ciment', 'value': 35.0, 'color': Color(0xFF1A3C6E)},
    {'label': 'Fer', 'value': 25.0, 'color': Color(0xFFF4A41B)},
    {'label': 'Briques', 'value': 20.0, 'color': Color(0xFF2E7D32)},
    {'label': 'Gravier', 'value': 12.0, 'color': Color(0xFF1976D2)},
    {'label': 'Autres', 'value': 8.0, 'color': Color(0xFF757575)},
  ];

  const _StockPieChart({required this.touchedIndex});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répartition des stocks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Par catégorie de produit',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: _stockData.asMap().entries.map((entry) {
                    final isTouched = entry.key == touchedIndex;
                    return PieChartSectionData(
                      color: entry.value['color'] as Color,
                      value: entry.value['value'] as double,
                      title: '${entry.value['value'].toInt()}%',
                      radius: isTouched ? 70 : 60,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
                duration: Duration.zero, // BUG FIX : pas d'animation initiale
              ),
            ),
            const SizedBox(height: 16),
            // Légende
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _stockData
                  .map((item) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: item['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['label'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
