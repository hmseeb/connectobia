part of 'realtime_messaging_bloc.dart';

final class MessageNotSent extends RealtimeMessagingState {
  final String message;

  MessageNotSent(this.message);
}

final class MessageSending extends RealtimeMessagingState {
  final String message;

  MessageSending(this.message);
}

final class MessageSent extends RealtimeMessagingState {
  final Message message;

  MessageSent(this.message);
}

final class MessagesLoaded extends RealtimeMessagingState {
  final Messages messages;
  final String selfId;

  MessagesLoaded(this.messages, this.selfId);
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
