import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sfmc_flutter/core/constants/api_constants.dart';
import 'package:sfmc_flutter/features/auth/models/user_model.dart';
import 'package:sfmc_flutter/services/http_client.dart';

class AuthService {
  final HttpClient _httpClient = HttpClient();

  Future<AuthResponse> login(String email, String password) async {
    final response = await _httpClient.post(
      ApiConstants.login,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Échec de connexion');
    }
  }

  Future<AuthResponse> register(
    String email,
    String password, {
    String role = 'client',
  }) async {
    final response = await _httpClient.post(
      ApiConstants.register,
      body: jsonEncode({'email': email, 'password': password, 'role': role}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Échec d\'inscription');
    }
  }

  Future<bool> verifyToken(String token) async {
    final response = await http.post(
      Uri.parse('${HttpClient.baseUrl}${ApiConstants.verifyToken}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
