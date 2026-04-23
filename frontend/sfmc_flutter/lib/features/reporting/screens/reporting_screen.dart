import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/widgets/loading_widget.dart';
import 'package:sfmc_flutter/features/reporting/providers/reporting_provider.dart';
import 'package:sfmc_flutter/features/reporting/widgets/sales_chart.dart';
import 'package:sfmc_flutter/features/reporting/widgets/kpi_summary.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportingProvider>().fetchDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporting & Analytique'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ventes'),
            Tab(text: 'Stock'),
            Tab(text: 'Production'),
            Tab(text: 'Finances'),
          ],
        ),
      ),
      body: Consumer<ReportingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              SalesChart(data: provider.salesData),
              KpiSummary(data: provider.stockReport),
              KpiSummary(data: provider.productionReport),
              KpiSummary(data: provider.financeReport),
            ],
          );
        },
      ),
    );
  }
}
