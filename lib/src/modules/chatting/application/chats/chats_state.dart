part of 'chats_bloc.dart';

final class ChatCreated extends ChatsState {
  final Chats chat;

  ChatCreated(this.chat);
}

final class ChatsInitial extends ChatsState {}

final class ChatsLoaded extends ChatsState {
  final Chats chats;

  ChatsLoaded(this.chats);
}

final class ChatsLoading extends ChatsState {}

final class ChatsLoadingError extends ChatsState {
  final String message;

  ChatsLoadingError(this.message);
}

@immutable
sealed class ChatsState {}

final class ChatUpdated extends ChatsState {
  final Chat chat;

  ChatUpdated(this.chat);
}
