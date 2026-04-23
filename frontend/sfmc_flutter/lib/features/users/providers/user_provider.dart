import 'package:flutter/material.dart';
import 'package:sfmc_flutter/features/users/models/user_profile_model.dart';
import 'package:sfmc_flutter/features/users/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _service = UserService();
  List<UserProfile> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserProfile> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _service.getAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(UserProfile user) async {
    try {
      final newUser = await _service.createUser(user);
      _users.add(newUser);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(int id, UserProfile user) async {
    try {
      final updated = await _service.updateUser(id, user);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await _service.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
