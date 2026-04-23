import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/utils/formatters.dart';
import 'package:sfmc_flutter/core/utils/validators.dart';
import 'package:sfmc_flutter/core/widgets/custom_button.dart';
import 'package:sfmc_flutter/core/widgets/custom_text_field.dart';
import 'package:sfmc_flutter/features/products/models/product_model.dart';
import 'package:sfmc_flutter/features/products/providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _prixController;
  String _categorie = 'ciment';
  String _unite = 'unité';
  bool _isLoading = false;

  final List<String> _categories = [
    'ciment',
    'fer',
    'brique',
    'granulat',
    'autre',
  ];
  final List<String> _unites = ['sac', 'barre', 'pièce', 'tonne', 'unité'];

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.product?.nom);
    _descriptionController = TextEditingController(
      text: widget.product?.description,
    );
    _prixController = TextEditingController(
      text: widget.product?.prixUnitaire.toString(),
    );
    if (widget.product != null) {
      _categorie = widget.product!.categorie;
      _unite = widget.product!.unite;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final product = Product(
        id: widget.product?.id,
        nom: _nomController.text.trim(),
        description: _descriptionController.text.trim(),
        categorie: _categorie,
        unite: _unite,
        prixUnitaire: double.parse(_prixController.text.trim()),
      );

      final provider = context.read<ProductProvider>();
      bool success;

      if (widget.product == null) {
        success = await provider.createProduct(product);
      } else {
        success = await provider.updateProduct(widget.product!.id!, product);
      }

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null ? 'Produit créé' : 'Produit mis à jour',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Une erreur est survenue'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Nouveau produit' : 'Modifier le produit',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Nom du produit',
                controller: _nomController,
                validator: (v) => Validators.validateRequired(v, 'Nom'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categorie,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(Formatters.capitalize(c)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categorie = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _unite,
                decoration: const InputDecoration(labelText: 'Unité'),
                items: _unites
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (value) => setState(() => _unite = value!),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Prix unitaire (FCFA)',
                controller: _prixController,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.validatePositiveNumber(v, 'Prix'),
                prefixIcon: const Icon(Icons.monetization_on),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: widget.product == null ? 'Créer' : 'Mettre à jour',
                onPressed: _saveProduct,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
