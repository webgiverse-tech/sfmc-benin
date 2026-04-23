import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/utils/formatters.dart';
import 'package:sfmc_flutter/core/widgets/custom_button.dart';
import 'package:sfmc_flutter/features/billing/models/invoice_model.dart';
import 'package:sfmc_flutter/features/billing/providers/billing_provider.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final int factureId;

  const InvoiceDetailScreen({super.key, required this.factureId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  Facture? _facture;
  bool _isLoading = true;
  final _montantController = TextEditingController();
  String _mode = 'especes';

  @override
  void initState() {
    super.initState();
    _loadFacture();
  }

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _loadFacture() async {
    final provider = context.read<BillingProvider>();
    try {
      final facture = provider.factures.firstWhere(
        (f) => f.id == widget.factureId,
      );
      setState(() {
        _facture = facture;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPaiement() async {
    final montant = double.tryParse(_montantController.text);
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Montant invalide')));
      return;
    }

    final paiement = Paiement(
      factureId: widget.factureId,
      montant: montant,
      mode: _mode,
    );

    final provider = context.read<BillingProvider>();
    final success = await provider.addPaiement(widget.factureId, paiement);

    if (success && mounted) {
      _montantController.clear();
      await _loadFacture();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paiement enregistré'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showPaiementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enregistrer un paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _montantController,
              decoration: const InputDecoration(labelText: 'Montant'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _mode,
              decoration: const InputDecoration(labelText: 'Mode de paiement'),
              items: const [
                DropdownMenuItem(value: 'especes', child: Text('Espèces')),
                DropdownMenuItem(value: 'virement', child: Text('Virement')),
                DropdownMenuItem(value: 'cheque', child: Text('Chèque')),
                DropdownMenuItem(
                  value: 'mobile_money',
                  child: Text('Mobile Money'),
                ),
              ],
              onChanged: (value) => _mode = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addPaiement();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_facture == null) {
      return const Scaffold(body: Center(child: Text('Facture non trouvée')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Facture #${_facture!.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails de la facture',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Client',
                      _facture!.clientNom ?? 'Client #${_facture!.clientId}',
                    ),
                    _buildInfoRow('Commande', '#${_facture!.orderId}'),
                    _buildInfoRow(
                      'Date émission',
                      Formatters.formatDate(_facture!.dateEmission),
                    ),
                    _buildInfoRow(
                      'Échéance',
                      _facture!.dateEcheance != null
                          ? Formatters.formatDate(_facture!.dateEcheance!)
                          : '-',
                    ),
                    _buildInfoRow(
                      'Montant total',
                      Formatters.formatCurrency(_facture!.montantTotal),
                    ),
                    _buildInfoRow(
                      'Montant payé',
                      Formatters.formatCurrency(_facture!.montantPaye),
                    ),
                    _buildInfoRow(
                      'Reste à payer',
                      Formatters.formatCurrency(_facture!.resteAPayer),
                      color: _facture!.resteAPayer > 0
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                    _buildInfoRow('Statut', _buildStatusChip(_facture!.statut)),
                  ],
                ),
              ),
            ),
            if (_facture!.paiements != null &&
                _facture!.paiements!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historique des paiements',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ..._facture!.paiements!.map(
                        (p) => ListTile(
                          title: Text(Formatters.formatCurrency(p.montant)),
                          subtitle: Text(
                            '${p.mode} - ${p.date != null ? Formatters.formatDate(p.date!) : ''}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_facture!.resteAPayer > 0) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Enregistrer un paiement',
                onPressed: _showPaiementDialog,
                icon: Icons.payment,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: value is Widget
                ? value
                : Text(
                    value.toString(),
                    style: color != null
                        ? TextStyle(color: color, fontWeight: FontWeight.bold)
                        : null,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'paid':
        color = AppColors.success;
        label = 'Payée';
        break;
      case 'partial':
        color = AppColors.warning;
        label = 'Partiel';
        break;
      default:
        color = AppColors.danger;
        label = 'Impayée';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
