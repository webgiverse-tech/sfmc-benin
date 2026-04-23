import 'dart:convert';
import 'package:sfmc_flutter/core/constants/api_constants.dart';
import 'package:sfmc_flutter/features/users/models/user_profile_model.dart';
import 'package:sfmc_flutter/services/http_client.dart';

class UserService {
  final HttpClient _httpClient = HttpClient();

  Future<List<UserProfile>> getAllUsers() async {
    final response = await _httpClient.get(ApiConstants.users);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();
    }
    throw Exception('Erreur chargement utilisateurs');
  }

  Future<UserProfile> createUser(UserProfile user) async {
    final response = await _httpClient.post(
      ApiConstants.users,
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return UserProfile.fromJson(data['data']);
    }
    throw Exception('Erreur création utilisateur');
  }

  Future<UserProfile> updateUser(int id, UserProfile user) async {
    final response = await _httpClient.put(
      '${ApiConstants.users}/$id',
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserProfile.fromJson(data['data']);
    }
    throw Exception('Erreur mise à jour');
  }

  Future<void> deleteUser(int id) async {
    final response = await _httpClient.delete('${ApiConstants.users}/$id');
    if (response.statusCode != 200) {
      throw Exception('Erreur suppression');
    }
  }
}
