import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/widgets/loading_widget.dart';
import 'package:sfmc_flutter/features/products/providers/product_provider.dart';
import 'package:sfmc_flutter/features/products/widgets/product_card.dart';
import 'package:sfmc_flutter/features/products/screens/product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Chargement des produits...');
          }

          if (provider.error != null) {
            return Center(child: Text('Erreur: ${provider.error}'));
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Aucun produit trouvé'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductFormScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un produit'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchProducts,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return ProductCard(product: product);
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrer les produits'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Toutes')),
                  DropdownMenuItem(value: 'ciment', child: Text('Ciment')),
                  DropdownMenuItem(value: 'fer', child: Text('Fer')),
                  DropdownMenuItem(value: 'brique', child: Text('Brique')),
                  DropdownMenuItem(value: 'granulat', child: Text('Granulat')),
                ],
                onChanged: (value) {},
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
                // Appliquer filtre
                Navigator.pop(context);
              },
              child: const Text('Appliquer'),
            ),
          ],
        );
      },
    );
  }
}
