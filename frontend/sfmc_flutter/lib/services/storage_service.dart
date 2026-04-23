import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final userString = _prefs.getString(_userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  static Future<void> clearAll() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
