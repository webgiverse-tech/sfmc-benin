import 'dart:convert';
import 'package:sfmc_flutter/core/constants/api_constants.dart';
import 'package:sfmc_flutter/features/notifications/models/notification_model.dart';
import 'package:sfmc_flutter/services/http_client.dart';

class NotificationService {
  final HttpClient _httpClient = HttpClient();

  Future<List<AppNotification>> getUserNotifications(int userId) async {
    final response = await _httpClient.get(
      '${ApiConstants.notifications}/user/$userId',
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    }
    throw Exception('Erreur chargement notifications');
  }

  Future<void> markAsRead(int notificationId) async {
    final response = await _httpClient.put(
      '${ApiConstants.notifications}/$notificationId/read',
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur marquage');
    }
  }

  Future<void> markAllAsRead(int userId) async {
    final response = await _httpClient.put(
      '${ApiConstants.notifications}/mark-all-read/$userId',
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur marquage');
    }
  }
}
