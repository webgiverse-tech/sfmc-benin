import 'package:flutter/material.dart';
import 'package:sfmc_flutter/core/constants/app_colors.dart';
import 'package:sfmc_flutter/core/utils/formatters.dart';
import 'package:sfmc_flutter/features/notifications/models/notification_model.dart';

class NotificationList extends StatelessWidget {
  final List<AppNotification> notifications;

  const NotificationList({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune notification'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(context, notification);
      },
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
  ) {
    Color typeColor;
    IconData typeIcon;
    switch (notification.type) {
      case 'success':
        typeColor = AppColors.success;
        typeIcon = Icons.check_circle;
        break;
      case 'warning':
        typeColor = AppColors.warning;
        typeIcon = Icons.warning;
        break;
      case 'error':
        typeColor = AppColors.danger;
        typeIcon = Icons.error;
        break;
      default:
        typeColor = AppColors.info;
        typeIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: notification.read ? null : AppColors.accent.withOpacity(0.3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.1),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          notification.titre,
          style: TextStyle(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              Formatters.formatDateTime(notification.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: notification.read
            ? null
            : IconButton(
                icon: const Icon(Icons.check, color: AppColors.success),
                onPressed: () {
                  // Marquer comme lu via provider
                },
              ),
        onTap: () {
          // Voir détail ou marquer comme lu
        },
      ),
    );
  }
}
