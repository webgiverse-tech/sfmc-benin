import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/utils/validators.dart';
import 'package:sfmc_flutter/core/widgets/custom_button.dart';
import 'package:sfmc_flutter/core/widgets/custom_text_field.dart';
import 'package:sfmc_flutter/features/products/providers/product_provider.dart';
import 'package:sfmc_flutter/features/production/models/production_model.dart';
import 'package:sfmc_flutter/features/production/providers/production_provider.dart';

class ProductionFormScreen extends StatefulWidget {
  const ProductionFormScreen({super.key});

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dateDebut;
  int? _selectedProductId;
  int? _selectedMachineId;
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedProductId != null) {
      setState(() => _isLoading = true);

      final order = ProductionOrder(
        productId: _selectedProductId!,
        quantityTarget: double.parse(_quantityController.text),
        dateDebut: _dateDebut,
        machineId: _selectedMachineId,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      final provider = context.read<ProductionProvider>();
      final success = await provider.createProductionOrder(order);

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ordre de production créé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dateDebut = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final productionProvider = context.watch<ProductionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel ordre de production')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              CustomTextField(
                label: 'Quantité cible',
                controller: _quantityController,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    Validators.validatePositiveNumber(v, 'Quantité'),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date de début'),
                  child: Text(
                    _dateDebut != null
                        ? '${_dateDebut!.day}/${_dateDebut!.month}/${_dateDebut!.year}'
                        : 'Sélectionner une date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Machine (optionnel)',
                ),
                items: productionProvider.machines
                    .where((m) => m.statut == 'available')
                    .map((m) {
                      return DropdownMenuItem(
                        value: m.id,
                        child: Text('${m.nom} (${m.capaciteJour}/jour)'),
                      );
                    })
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedMachineId = value),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Notes',
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Créer',
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
