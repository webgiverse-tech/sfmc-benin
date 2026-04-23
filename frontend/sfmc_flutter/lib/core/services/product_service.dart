import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  static Future<List<Product>> getAll() async {
    final data = await ApiService.get('/products');
    return (data['data'] as List).map((p) => Product.fromJson(p)).toList();
  }

  static Future<Product> getById(int id) async {
    final data = await ApiService.get('/products/$id');
    return Product.fromJson(data['data']);
  }

  static Future<Product> create(Map<String, dynamic> product) async {
    final data = await ApiService.post('/products', product);
    return Product.fromJson(data['data']);
  }

  static Future<Product> update(int id, Map<String, dynamic> product) async {
    final data = await ApiService.put('/products/$id', product);
    return Product.fromJson(data['data']);
  }

  static Future<void> delete(int id) async {
    await ApiService.delete('/products/$id');
  }
}
