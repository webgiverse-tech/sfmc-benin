import 'dart:convert';
import 'package:sfmc_flutter/core/constants/api_constants.dart';
import 'package:sfmc_flutter/features/orders/models/order_model.dart';
import 'package:sfmc_flutter/services/http_client.dart';

class OrderService {
  final HttpClient _httpClient = HttpClient();

  Future<List<Order>> getAllOrders() async {
    final response = await _httpClient.get(ApiConstants.orders);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    }
    throw Exception('Erreur chargement commandes');
  }

  Future<Order> getOrderById(int id) async {
    final response = await _httpClient.get('${ApiConstants.orders}/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data['data']);
    }
    throw Exception('Commande non trouvée');
  }

  Future<Order> createOrder(Order order) async {
    final response = await _httpClient.post(
      ApiConstants.orders,
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data['data']);
    }
    throw Exception('Erreur création commande');
  }

  Future<Order> updateOrderStatus(int id, String status) async {
    final response = await _httpClient.put(
      '${ApiConstants.orders}/$id/status',
      body: jsonEncode({'statut': status}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data['data']);
    }
    throw Exception('Erreur mise à jour statut');
  }
}
