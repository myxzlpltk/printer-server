import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printer_server/controllers/notification_notifier.dart';
import 'package:printer_server/shared/notification.dart';

class NotificationScope extends ConsumerWidget {
  const NotificationScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(notificationProvider, (previous, next) {
      if (next.notifications.isNotEmpty) {
        final notification = next.notifications.removeAt(0);
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(notification.message, style: const TextStyle(color: Colors.white)),
          backgroundColor: switch (notification.type) {
            NotificationType.success => Colors.green.shade500,
            NotificationType.error => Colors.red.shade500,
          },
        ));
      }
    });

    return child;
  }
}
