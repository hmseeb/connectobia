part of 'notifications_bloc.dart';

class MessageReceived extends NotificationsState {
  final Message message;
  final String avatar;
  final String name;
  final String userId;
  final String collectionId;
  final String chatId;
  final bool hasConnectedInstagram;

  MessageReceived({
    required this.message,
    required this.avatar,
    required this.name,
    required this.userId,
    required this.collectionId,
    required this.chatId,
    required this.hasConnectedInstagram,
  });
}

final class NotificationsInitial extends NotificationsState {}

@immutable
sealed class NotificationsState {}
