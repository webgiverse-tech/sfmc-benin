import 'dart:convert';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    }, withAuth: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', response['token']);
    await prefs.setString('user', jsonEncode(response['user']));
    return response;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}
