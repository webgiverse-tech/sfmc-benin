import 'package:flutter/material.dart';
import 'package:sfmc_flutter/features/auth/models/user_model.dart';
import 'package:sfmc_flutter/features/auth/services/auth_service.dart';
import 'package:sfmc_flutter/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _currentUser != null;

  AuthProvider() {
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    _token = await StorageService.getToken();
    final userJson = await StorageService.getUser();
    if (userJson != null) {
      _currentUser = User.fromJson(userJson);
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      _token = response.token;
      _currentUser = response.user;
      await StorageService.saveToken(response.token);
      await StorageService.saveUser(response.user.toJson());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password, {
    String role = 'client',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(email, password, role: role);
      _token = response.token;
      _currentUser = response.user;
      await StorageService.saveToken(response.token);
      await StorageService.saveUser(response.user.toJson());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await StorageService.clearAll();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
