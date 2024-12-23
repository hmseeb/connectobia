part of 'chats_bloc.dart';

@immutable
sealed class ChatsEvent {}

class CreateChat extends ChatsEvent {
  final String recipientId;
  final String message;

  CreateChat(this.recipientId, this.message);
}

class CreatedChat extends ChatsEvent {
  final Chats prevChats;
  final Chat newChat;

  CreatedChat({required this.newChat, required this.prevChats});
}

class GetChatId extends ChatsEvent {
  final String recipientId;

  GetChatId(this.recipientId);
}

class GetChats extends ChatsEvent {
  GetChats();
}

class SubscribeChats extends ChatsEvent {
  final Chats prevChats;
  SubscribeChats({required this.prevChats});
}

class UnsubscribeChats extends ChatsEvent {
  UnsubscribeChats();
}

class UpdatedChat extends ChatsEvent {
  final Chats prevChats;
  final Chat newChat;

  UpdatedChat({required this.newChat, required this.prevChats});
}
