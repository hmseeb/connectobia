part of 'messages_bloc.dart';

@immutable
sealed class MessagesEvent {}

class GetMessages extends MessagesEvent {
  final String chatId;

  GetMessages(this.chatId);
}

class SendMessage extends MessagesEvent {
  final String chatId;
  final String recipientId;
  final String message;

  SendMessage(this.chatId, this.message, this.recipientId);
}

class CreateChat extends MessagesEvent {
  final String recipientId;
  final String message;

  CreateChat(this.recipientId, this.message);
}

class GetMessagesByChatId extends MessagesEvent {
  GetMessagesByChatId();
}

class GetChats extends MessagesEvent {
  GetChats();
}
