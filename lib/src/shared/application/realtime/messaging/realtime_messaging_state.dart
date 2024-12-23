part of 'realtime_messaging_bloc.dart';

final class RealtimeMessageReceived extends RealtimeMessagingState {
  final Message message;
  final String avatar;
  final String name;
  final String userId;
  final String collectionId;
  final String chatId;
  final bool hasConnectedInstagram;

  RealtimeMessageReceived({
    required this.message,
    required this.avatar,
    required this.name,
    required this.userId,
    required this.collectionId,
    required this.chatId,
    required this.hasConnectedInstagram,
  });
}

final class RealtimeMessagingError extends RealtimeMessagingState {
  final String error;

  RealtimeMessagingError(this.error);
}

final class RealtimeMessagingInitial extends RealtimeMessagingState {}

@immutable
sealed class RealtimeMessagingState {}

final class RealtimeMessagingSubscribed extends RealtimeMessagingState {}
