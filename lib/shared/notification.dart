enum NotificationType { success, error }

class Notification {
  const Notification({required this.message, required this.type});

  final String message;
  final NotificationType type;
}