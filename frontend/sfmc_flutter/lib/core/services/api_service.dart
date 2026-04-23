import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint, {bool withAuth = true}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint, {bool withAuth = true}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Une erreur est survenue');
    }
  }
}
