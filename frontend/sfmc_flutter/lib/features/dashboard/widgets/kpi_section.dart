import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/widgets/stat_card.dart';

class KpiSection extends StatelessWidget {
  const KpiSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Dans un cas réel, ces données viendraient d'un provider
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const [
        StatCard(
          title: 'Commandes totales',
          value: '156',
          icon: Icons.shopping_cart,
          color: AppColors.primary,
          change: 12.5,
        ),
        StatCard(
          title: 'Stock Global',
          value: '1,250',
          icon: Icons.inventory,
          color: AppColors.secondary,
          change: -3.2,
        ),
        StatCard(
          title: 'Production jour',
          value: '328',
          icon: Icons.factory,
          color: AppColors.info,
          change: 5.0,
        ),
        StatCard(
          title: 'CA du mois',
          value: '2.5M FCFA',
          icon: Icons.monetization_on,
          color: AppColors.success,
          change: 8.3,
        ),
        StatCard(
          title: 'Alertes stock',
          value: '3',
          icon: Icons.warning,
          color: AppColors.danger,
          subtitle: '2 critiques',
        ),
        StatCard(
          title: 'Livraisons en attente',
          value: '8',
          icon: Icons.local_shipping,
          color: AppColors.warning,
        ),
      ],
    );
  }
}
