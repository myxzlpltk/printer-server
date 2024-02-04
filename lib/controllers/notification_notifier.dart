import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printer_server/controllers/notification_state.dart';
import 'package:printer_server/shared/notification.dart';

final notificationProvider = StateNotifierProvider.autoDispose<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this.ref) : super(const NotificationState());

  final Ref ref;

  /// When user add success notification
  void success(String message) {
    final notification = Notification(message: message, type: NotificationType.success);
    state = state.copyWith(notifications: [...state.notifications, notification]);
  }

  /// When user add error notification
  void error(String message) {
    final notification = Notification(message: message, type: NotificationType.error);
    state = state.copyWith(notifications: [...state.notifications, notification]);
  }
}
