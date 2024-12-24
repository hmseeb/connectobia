part of 'notifications_bloc.dart';

final class MessageNotificationReceived extends NotificationsEvent {
  final Message message;
  final String avatar;
  final String name;
  final String userId;
  final String collectionId;
  final String chatId;
  final bool hasConnectedInstagram;

  MessageNotificationReceived({
    required this.message,
    required this.avatar,
    required this.name,
    required this.userId,
    required this.collectionId,
    required this.chatId,
    required this.hasConnectedInstagram,
  });
}

@immutable
sealed class NotificationsEvent {}
