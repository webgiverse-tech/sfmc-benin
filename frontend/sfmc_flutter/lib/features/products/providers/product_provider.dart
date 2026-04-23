import 'package:flutter/material.dart';
import 'package:sfmc_flutter/features/products/models/product_model.dart';
import 'package:sfmc_flutter/features/products/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String? _filterCategory;

  List<Product> get products => _filterCategory == null
      ? _products
      : _products.where((p) => p.categorie == _filterCategory).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filterCategory => _filterCategory;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.getAllProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct(Product product) async {
    try {
      final newProduct = await _service.createProduct(product);
      _products.add(newProduct);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(int id, Product product) async {
    try {
      final updated = await _service.updateProduct(id, product);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _service.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
