part of 'messages_bloc.dart';

@immutable
sealed class MessagesState {}

final class MessagesInitial extends MessagesState {}

final class MessagesLoading extends MessagesState {}

final class MessagesLoaded extends MessagesState {
  final Messages messages;

  MessagesLoaded(this.messages);
}

final class MessagesError extends MessagesState {
  final String message;

  MessagesError(this.message);
}

final class ChatsLoaded extends MessagesState {
  final Chats chats;

  ChatsLoaded(this.chats);
}

final class ChatCreated extends MessagesState {
  final Chat chat;

  ChatCreated(this.chat);
}

final class MessageSent extends MessagesState {
  final String messages;

  MessageSent(this.messages);
}
