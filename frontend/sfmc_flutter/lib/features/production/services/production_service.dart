import 'dart:convert';
import 'package:sfmc_flutter/core/constants/api_constants.dart';
import 'package:sfmc_flutter/features/production/models/production_model.dart';
import 'package:sfmc_flutter/services/http_client.dart';

class ProductionService {
  final HttpClient _httpClient = HttpClient();

  Future<List<ProductionOrder>> getAllProductionOrders() async {
    final response = await _httpClient.get(ApiConstants.production);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => ProductionOrder.fromJson(json))
          .toList();
    }
    throw Exception('Erreur chargement');
  }

  Future<List<Machine>> getMachines() async {
    final response = await _httpClient.get(ApiConstants.machines);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => Machine.fromJson(json))
          .toList();
    }
    throw Exception('Erreur chargement machines');
  }

  Future<ProductionOrder> createProductionOrder(ProductionOrder order) async {
    final response = await _httpClient.post(
      ApiConstants.production,
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ProductionOrder.fromJson(data['data']);
    }
    throw Exception('Erreur création');
  }

  Future<ProductionOrder> updateProductionStatus(
    int id,
    String status,
    double? quantityProduced,
  ) async {
    final body = {'statut': status};
    if (quantityProduced != null) body['quantity_produced'] = quantityProduced as String;
    final response = await _httpClient.put(
      '${ApiConstants.production}/$id/status',
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductionOrder.fromJson(data['data']);
    }
    throw Exception('Erreur mise à jour');
  }
}
