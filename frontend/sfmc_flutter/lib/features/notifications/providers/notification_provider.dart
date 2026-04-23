import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/features/auth/providers/auth_provider.dart';
import 'package:sfmc_flutter/features/notifications/models/notification_model.dart';
import 'package:sfmc_flutter/features/notifications/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  String? _filterType;
  bool _showOnlyUnread = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filterType => _filterType;
  bool get showOnlyUnread => _showOnlyUnread;

  List<AppNotification> get filteredNotifications {
    var filtered = _notifications;
    if (_filterType != null) {
      filtered = filtered.where((n) => n.type == _filterType).toList();
    }
    if (_showOnlyUnread) {
      filtered = filtered.where((n) => !n.read).toList();
    }
    return filtered;
  }

  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> fetchNotifications() async {
    final authProvider = Provider.of<AuthProvider>(_getContext(), listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _service.getUserNotifications(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(read: true);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final authProvider = Provider.of<AuthProvider>(_getContext(), listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    try {
      await _service.markAllAsRead(userId);
      _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setFilterType(String? type) {
    _filterType = type;
    notifyListeners();
  }

  void toggleShowOnlyUnread(bool value) {
    _showOnlyUnread = value;
    notifyListeners();
  }

  BuildContext _getContext() {
    // À utiliser avec prudence, normalement le provider doit être construit avec context.
    // Pour simplifier, nous supposons que le Provider est utilisé dans un contexte valide.
    throw UnimplementedError('Contexte non disponible, utilisez un autre pattern');
  }
}