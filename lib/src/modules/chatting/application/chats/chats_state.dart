part of 'chats_bloc.dart';

@immutable
sealed class ChatsState {}

final class ChatsInitial extends ChatsState {}

final class ChatsLoading extends ChatsState {}

final class ChatsLoadingError extends ChatsState {
  final String message;

  ChatsLoadingError(this.message);
}

final class ChatsLoaded extends ChatsState {
  final Chats chats;

  ChatsLoaded(this.chats);
}

final class ChatCreated extends ChatsState {
  final Chats chat;

  ChatCreated(this.chat);
}
