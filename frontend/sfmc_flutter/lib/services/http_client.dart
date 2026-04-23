import 'package:http/http.dart' as http;
import 'package:sfmc_flutter/services/storage_service.dart';

class HttpClient {
  static const String baseUrl = 'http://localhost:3000/api';
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    if (token != null) {
      _headers['Authorization'] = 'Bearer $token';
    }
    return _headers;
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }

  Future<http.Response> post(String endpoint, {Object? body}) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> put(String endpoint, {Object? body}) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
  }
}
