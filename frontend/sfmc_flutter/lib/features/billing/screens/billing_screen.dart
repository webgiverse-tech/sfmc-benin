import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/widgets/loading_widget.dart';
import 'package:sfmc_flutter/features/billing/providers/billing_provider.dart';
import 'package:sfmc_flutter/features/billing/widgets/invoice_table.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillingProvider>().fetchFactures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              // Voir statistiques
            },
          ),
        ],
      ),
      body: Consumer<BillingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Chargement...');
          }

          return RefreshIndicator(
            onRefresh: provider.fetchFactures,
            child: InvoiceTable(factures: provider.filteredFactures),
          );
        },
      ),
    );
  }
}
