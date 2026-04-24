// lib/features/dashboard/widgets/kpi_section.dart — BUG FIX #5g
// Correction : chargement différé des KPIs (simulation API)
// + StatCards avec isLoading=true pendant le fetch
// + Wrap avec clé stable pour éviter les rebuilds inutiles

import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/widgets/stat_card.dart';

class KpiSection extends StatefulWidget {
  const KpiSection({super.key});

  @override
  State<KpiSection> createState() => _KpiSectionState();
}

class _KpiSectionState extends State<KpiSection> {
  // BUG FIX #5g : les données sont chargées de façon asynchrone
  // → on affiche le skeleton pendant le chargement (isLoading=true)
  // au lieu d'afficher 6 shimmer en permanence
  bool _isLoading = true;
  Map<String, String> _kpiData = {};

  @override
  void initState() {
    super.initState();
    _loadKpiData();
  }

  Future<void> _loadKpiData() async {
    // Simulation d'un appel API (remplacer par l'appel réel au reporting service)
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _kpiData = {
        'commandes': '156',
        'stock': '1 250',
        'production': '328',
        'ca': '2,5M FCFA',
        'alertes': '3',
        'livraisons': '8',
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        StatCard(
          key: const ValueKey('kpi_commandes'),
          title: 'Commandes totales',
          value: _isLoading ? '' : _kpiData['commandes']!,
          icon: Icons.shopping_cart_outlined,
          color: AppColors.primary,
          change: _isLoading ? null : 12.5,
          isLoading: _isLoading,
        ),
        StatCard(
          key: const ValueKey('kpi_stock'),
          title: 'Stock Global',
          value: _isLoading ? '' : _kpiData['stock']!,
          icon: Icons.inventory_2_outlined,
          color: AppColors.secondary,
          change: _isLoading ? null : -3.2,
          isLoading: _isLoading,
        ),
        StatCard(
          key: const ValueKey('kpi_production'),
          title: 'Production du jour',
          value: _isLoading ? '' : _kpiData['production']!,
          icon: Icons.factory_outlined,
          color: AppColors.info,
          change: _isLoading ? null : 5.0,
          isLoading: _isLoading,
        ),
        StatCard(
          key: const ValueKey('kpi_ca'),
          title: 'CA du mois',
          value: _isLoading ? '' : _kpiData['ca']!,
          icon: Icons.monetization_on_outlined,
          color: AppColors.success,
          change: _isLoading ? null : 8.3,
          isLoading: _isLoading,
        ),
        StatCard(
          key: const ValueKey('kpi_alertes'),
          title: 'Alertes stock',
          value: _isLoading ? '' : _kpiData['alertes']!,
          icon: Icons.warning_amber_outlined,
          color: AppColors.danger,
          subtitle: _isLoading ? null : '2 critiques',
          isLoading: _isLoading,
        ),
        StatCard(
          key: const ValueKey('kpi_livraisons'),
          title: 'Livraisons en attente',
          value: _isLoading ? '' : _kpiData['livraisons']!,
          icon: Icons.local_shipping_outlined,
          color: AppColors.warning,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
