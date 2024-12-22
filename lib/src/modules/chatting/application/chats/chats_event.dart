part of 'chats_bloc.dart';

@immutable
sealed class ChatsEvent {}

class CreateChat extends ChatsEvent {
  final String recipientId;
  final String message;

  CreateChat(this.recipientId, this.message);
}

class GetChats extends ChatsEvent {
  GetChats();
}

class GetChatId extends ChatsEvent {
  final String recipientId;

  GetChatId(this.recipientId);
}
