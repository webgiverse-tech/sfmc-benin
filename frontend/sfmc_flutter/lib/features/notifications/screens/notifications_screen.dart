import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfmc_flutter/core/widgets/loading_widget.dart';
import 'package:sfmc_flutter/features/notifications/providers/notification_provider.dart';
import 'package:sfmc_flutter/features/notifications/widgets/notification_list.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          return RefreshIndicator(
            onRefresh: provider.fetchNotifications,
            child: NotificationList(notifications: provider.filteredNotifications),
          );
        },
      ),
    );
  }
}