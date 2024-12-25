part of 'realtime_messaging_bloc.dart';

class MessageNotificationReceived extends RealtimeMessagingState {
  final String message;
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
    this.hasConnectedInstagram = false,
  });
}

final class MessageNotSent extends RealtimeMessagingState {
  final String message;

  MessageNotSent(this.message);
}

final class MessageSending extends RealtimeMessagingState {
  final String message;

  MessageSending(this.message);
}

final class MessagesLoaded extends RealtimeMessagingState {
  final Messages messages;
  final String selfId;

  MessagesLoaded({required this.messages, required this.selfId});
}

final class MessagesLoading extends RealtimeMessagingState {}

final class MessagesLoadingError extends RealtimeMessagingState {
  final String message;

  MessagesLoadingError(this.message);
}

final class NoMessages extends RealtimeMessagingState {}

final class RealtimeMessagingError extends RealtimeMessagingState {
  final String error;

  RealtimeMessagingError(this.error);
}

final class RealtimeMessagingInitial extends RealtimeMessagingState {}

@immutable
sealed class RealtimeMessagingState {}

final class RealtimeMessagingSubscribed extends RealtimeMessagingState {}
