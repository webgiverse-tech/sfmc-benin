import 'dart:convert';
import 'package:sfmc_flutter/core/constants/api_constants.dart';
import 'package:sfmc_flutter/features/products/models/product_model.dart';
import 'package:sfmc_flutter/services/http_client.dart';

class ProductService {
  final HttpClient _httpClient = HttpClient();

  Future<List<Product>> getAllProducts() async {
    final response = await _httpClient.get(ApiConstants.products);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    }
    throw Exception('Erreur lors du chargement des produits');
  }

  Future<Product> getProductById(int id) async {
    final response = await _httpClient.get('${ApiConstants.products}/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data['data']);
    }
    throw Exception('Produit non trouvé');
  }

  Future<Product> createProduct(Product product) async {
    final response = await _httpClient.post(
      ApiConstants.products,
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data['data']);
    }
    throw Exception('Erreur lors de la création du produit');
  }

  Future<Product> updateProduct(int id, Product product) async {
    final response = await _httpClient.put(
      '${ApiConstants.products}/$id',
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data['data']);
    }
    throw Exception('Erreur lors de la mise à jour');
  }

  Future<void> deleteProduct(int id) async {
    final response = await _httpClient.delete('${ApiConstants.products}/$id');
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression');
    }
  }
}
