part of 'messages_bloc.dart';

@immutable
sealed class MessagesState {}

final class MessagesInitial extends MessagesState {}

final class MessagesLoading extends MessagesState {}

final class MessagesLoaded extends MessagesState {
  final Messages messages;
  final String selfId;

  MessagesLoaded(this.messages, this.selfId);
}

final class MessagesLoadingError extends MessagesState {
  final String message;

  MessagesLoadingError(this.message);
}

final class MessageSending extends MessagesState {
  final String message;

  MessageSending(this.message);
}

final class MessageSent extends MessagesState {
  final Message message;

  MessageSent(this.message);
}

final class MessageNotSent extends MessagesState {
  final String message;

  MessageNotSent(this.message);
}
