import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String get role => _user?['role'] ?? 'client';

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = await AuthService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await AuthService.login(email, password);
      _user = response['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}
