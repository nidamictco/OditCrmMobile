import 'package:odit_crm_mobile/feature/notification/model/notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  NotificationLoaded(this.notifications);

// ── unread count ──────────────────────────────────────────────────────────
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

// new
class NotificationDeleting extends NotificationState {
  final List<NotificationModel> notifications; // keeps UI showing list while deleting
  NotificationDeleting(this.notifications);
}

class NotificationDeleteError extends NotificationState {
  final List<NotificationModel> notifications; // restore list on error
  final String message;
  NotificationDeleteError(this.notifications, this.message);
}

