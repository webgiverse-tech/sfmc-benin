import 'dart:convert';
import 'package:sfmc_flutter/core/constants/api_constants.dart';
import 'package:sfmc_flutter/services/http_client.dart';

class ReportingService {
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _httpClient.get(ApiConstants.dashboard);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Erreur dashboard');
  }

  Future<List<dynamic>> getSalesReport({DateTime? start, DateTime? end}) async {
    String url = ApiConstants.salesReport;
    final params = <String, String>{};
    if (start != null) params['start_date'] = start.toIso8601String();
    if (end != null) params['end_date'] = end.toIso8601String();
    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    final response = await _httpClient.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Erreur rapport ventes');
  }

  Future<Map<String, dynamic>> getStockReport() async {
    final response = await _httpClient.get(ApiConstants.stockReport);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Erreur rapport stock');
  }

  Future<Map<String, dynamic>> getProductionReport({
    DateTime? start,
    DateTime? end,
  }) async {
    String url = ApiConstants.productionReport;
    final params = <String, String>{};
    if (start != null) params['start_date'] = start.toIso8601String();
    if (end != null) params['end_date'] = end.toIso8601String();
    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    final response = await _httpClient.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Erreur rapport production');
  }

  Future<Map<String, dynamic>> getFinanceReport({
    DateTime? start,
    DateTime? end,
  }) async {
    String url = ApiConstants.financeReport;
    final params = <String, String>{};
    if (start != null) params['start_date'] = start.toIso8601String();
    if (end != null) params['end_date'] = end.toIso8601String();
    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }
    final response = await _httpClient.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Erreur rapport finances');
  }
}
