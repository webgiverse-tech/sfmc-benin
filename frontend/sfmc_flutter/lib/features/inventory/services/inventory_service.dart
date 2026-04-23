import 'dart:convert';
import 'package:sfmc_flutter/core/constants/api_constants.dart';
import 'package:sfmc_flutter/features/inventory/models/stock_model.dart';
import 'package:sfmc_flutter/services/http_client.dart';

class InventoryService {
  final HttpClient _httpClient = HttpClient();

  Future<List<StockItem>> getFullInventory() async {
    final response = await _httpClient.get(ApiConstants.inventory);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => StockItem.fromJson(json))
          .toList();
    }
    throw Exception('Erreur chargement inventaire');
  }

  Future<List<StockMovement>> getMovements({
    Map<String, dynamic>? filters,
  }) async {
    var endpoint = ApiConstants.stockMovements;
    if (filters != null && filters.isNotEmpty) {
      final query = filters.entries.map((e) => '${e.key}=${e.value}').join('&');
      endpoint += '?$query';
    }
    final response = await _httpClient.get(endpoint);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => StockMovement.fromJson(json))
          .toList();
    }
    throw Exception('Erreur chargement mouvements');
  }

  Future<StockMovement> addMovement(StockMovement movement) async {
    final response = await _httpClient.post(
      '${ApiConstants.inventory}/movement',
      body: jsonEncode(movement.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return StockMovement.fromJson(data['data']);
    }
    throw Exception('Erreur ajout mouvement');
  }
}
