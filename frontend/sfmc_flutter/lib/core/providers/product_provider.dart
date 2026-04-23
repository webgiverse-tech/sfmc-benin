import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await ProductService.getAll();
    } catch (e) {
      // gérer l'erreur
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    final newProduct = await ProductService.create(data);
    _products.add(newProduct);
    notifyListeners();
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    final updated = await ProductService.update(id, data);
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    await ProductService.delete(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
