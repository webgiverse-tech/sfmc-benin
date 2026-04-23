import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/widgets/sidebar_menu.dart';
import 'package:sfmc_flutter/features/auth/providers/auth_provider.dart';
import 'package:sfmc_flutter/features/dashboard/widgets/kpi_section.dart';
import 'package:sfmc_flutter/features/dashboard/widgets/charts_section.dart';
import 'package:sfmc_flutter/features/dashboard/widgets/recent_orders_table.dart';
import 'package:sfmc_flutter/features/dashboard/widgets/stock_alerts_list.dart';
import 'package:sfmc_flutter/navigation/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigation vers notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
            },
          ),
        ],
      ),
      drawer: SidebarMenu(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${authProvider.currentUser?.email ?? 'Utilisateur'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const KpiSection(),
            const SizedBox(height: 24),
            const ChartsSection(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(children: const [RecentOrdersTable()]),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(children: const [StockAlertsList()])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
