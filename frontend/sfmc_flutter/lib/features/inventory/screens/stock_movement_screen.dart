import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/utils/validators.dart';
import 'package:sfmc_flutter/core/widgets/custom_button.dart';
import 'package:sfmc_flutter/core/widgets/custom_text_field.dart';
import 'package:sfmc_flutter/features/inventory/models/stock_model.dart';
import 'package:sfmc_flutter/features/inventory/providers/inventory_provider.dart';
import 'package:sfmc_flutter/features/products/providers/product_provider.dart';

class StockMovementScreen extends StatefulWidget {
  const StockMovementScreen({super.key});

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  String _type = 'IN';
  int? _selectedProductId;
  int? _selectedWarehouseId;
  bool _isLoading = false;

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _selectedProductId != null &&
        _selectedWarehouseId != null) {
      setState(() => _isLoading = true);

      final movement = StockMovement(
        productId: _selectedProductId!,
        warehouseId: _selectedWarehouseId!,
        type: _type,
        quantity: double.parse(_quantityController.text),
        reason: _reasonController.text.isNotEmpty
            ? _reasonController.text
            : null,
      );

      final provider = context.read<InventoryProvider>();
      final success = await provider.addMovement(movement);

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mouvement enregistré'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erreur'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau mouvement de stock')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type de mouvement',
                ),
                items: const [
                  DropdownMenuItem(value: 'IN', child: Text('Entrée')),
                  DropdownMenuItem(value: 'OUT', child: Text('Sortie')),
                ],
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Produit'),
                items: productProvider.products.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text(p.nom));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedProductId = value),
                validator: (value) =>
                    value == null ? 'Sélectionnez un produit' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Entrepôt'),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Entrepôt Principal Cotonou'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Entrepôt Secondaire Porto-Novo'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _selectedWarehouseId = value),
                validator: (value) =>
                    value == null ? 'Sélectionnez un entrepôt' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Quantité',
                controller: _quantityController,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    Validators.validatePositiveNumber(v, 'Quantité'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Raison (optionnel)',
                controller: _reasonController,
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Enregistrer',
                onPressed: _submit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
