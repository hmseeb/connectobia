part of 'notification_bloc.dart';

/// Event to fetch all notifications for a user
final class FetchNotifications extends NotificationEvent {}

/// Event to mark all notifications as read
final class MarkAllNotificationsAsRead extends NotificationEvent {}

/// Event to mark a notification as read
final class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  MarkNotificationAsRead(this.notificationId);
}

/// Event when a notification is received through subscription
final class NotificationArrived extends NotificationEvent {
  final NotificationModel notification;

  NotificationArrived(this.notification);
}

/// Base class for notification events
@immutable
sealed class NotificationEvent {}

/// Event to subscribe to notifications for a user
final class SubscribeToNotifications extends NotificationEvent {}

/// Event to unsubscribe from notifications
final class UnsubscribeFromNotifications extends NotificationEvent {}
