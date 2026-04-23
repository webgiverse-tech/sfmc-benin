import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/utils/formatters.dart';
import 'package:sfmc_flutter/core/widgets/custom_button.dart';
import 'package:sfmc_flutter/features/orders/models/order_model.dart';
import 'package:sfmc_flutter/features/orders/providers/order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final provider = context.read<OrderProvider>();
    try {
      // On suppose que la commande est déjà dans la liste ou on peut la charger
      final order = provider.orders.firstWhere((o) => o.id == widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final provider = context.read<OrderProvider>();
    final success = await provider.updateOrderStatus(widget.orderId, newStatus);
    if (success && mounted) {
      setState(() {
        _order = provider.orders.firstWhere((o) => o.id == widget.orderId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statut mis à jour'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showStatusDialog() {
    final statuses = [
      'pending',
      'validated',
      'shipped',
      'delivered',
      'cancelled',
    ];
    final labels = ['En attente', 'Validée', 'Expédiée', 'Livrée', 'Annulée'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le statut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.asMap().entries.map((entry) {
            return ListTile(
              title: Text(labels[entry.key]),
              leading: Radio<String>(
                value: entry.value,
                groupValue: _order?.statut,
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) _updateStatus(value);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_order == null) {
      return const Scaffold(body: Center(child: Text('Commande non trouvée')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Commande #${_order!.id}')),
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
                      'Informations générales',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Client', 'Client #${_order!.clientId}'),
                    _buildInfoRow(
                      'Date commande',
                      Formatters.formatDate(_order!.dateCommande),
                    ),
                    _buildInfoRow(
                      'Livraison prévue',
                      _order!.dateLivraisonPrevue != null
                          ? Formatters.formatDate(_order!.dateLivraisonPrevue!)
                          : '-',
                    ),
                    _buildInfoRow(
                      'Total',
                      Formatters.formatCurrency(_order!.total),
                    ),
                    _buildInfoRow('Statut', _buildStatusChip(_order!.statut)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Articles commandés',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ..._order!.items.map(
                      (item) => ListTile(
                        title: Text('Produit #${item.productId}'),
                        subtitle: Text(
                          '${item.quantity} x ${Formatters.formatCurrency(item.prixUnitaire)}',
                        ),
                        trailing: Text(
                          Formatters.formatCurrency(
                            item.quantity * item.prixUnitaire,
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total: ${Formatters.formatCurrency(_order!.total)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Changer le statut',
              onPressed: _showStatusDialog,
              icon: Icons.edit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
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
          Expanded(child: value is Widget ? value : Text(value.toString())),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'En attente';
        break;
      case 'validated':
        color = AppColors.info;
        label = 'Validée';
        break;
      case 'shipped':
        color = AppColors.primary;
        label = 'Expédiée';
        break;
      case 'delivered':
        color = AppColors.success;
        label = 'Livrée';
        break;
      case 'cancelled':
        color = AppColors.danger;
        label = 'Annulée';
        break;
      default:
        color = AppColors.textSecondary;
        label = status;
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
