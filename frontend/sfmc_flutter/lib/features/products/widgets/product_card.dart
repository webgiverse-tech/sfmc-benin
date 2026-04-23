import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/utils/formatters.dart';
import 'package:sfmc_flutter/features/products/models/product_model.dart';
import 'package:sfmc_flutter/features/products/screens/product_form_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigation vers détail
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: product.imageUrl != null
                        ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                        : const Icon(
                            Icons.inventory,
                            size: 50,
                            color: AppColors.primary,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.nom,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.formatCurrency(product.prixUnitaire),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Chip(
                    label: Text(Formatters.capitalize(product.categorie)),
                    backgroundColor: AppColors.accent,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Modifier'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductFormScreen(product: product),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(color: AppColors.danger),
                        ),
                        onTap: () => _confirmDelete(context),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${product.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              // Appeler la suppression via provider
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
