import 'package:equatable/equatable.dart';
import 'package:printer_server/shared/notification.dart';

class NotificationState extends Equatable {
  const NotificationState({
    this.notifications = const [],
  });

  final List<Notification> notifications;

  NotificationState copyWith({
    List<Notification>? notifications,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [notifications];
}
