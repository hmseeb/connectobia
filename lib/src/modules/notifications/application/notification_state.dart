part of 'notification_bloc.dart';

/// Error state for notification operations
final class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

/// Initial state for notifications
final class NotificationInitial extends NotificationState {}

/// State when a new notification is received
final class NotificationReceived extends NotificationState {
  final NotificationModel notification;

  NotificationReceived({
    required this.notification,
  });
}

/// State when notifications are successfully loaded
final class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });
}

/// Loading state when fetching notifications
final class NotificationsLoading extends NotificationState {}

/// Base class for notification states
@immutable
sealed class NotificationState {}
