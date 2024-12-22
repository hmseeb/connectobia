part of 'messages_bloc.dart';

@immutable
sealed class MessagesEvent {}

class GetMessagesByChatId extends MessagesEvent {
  final String chatId;

  GetMessagesByChatId(this.chatId);
}

class SendMessage extends MessagesEvent {
  final String recipientId;
  final String message;
  final String chatId;
  final Messages messages;

  SendMessage({
    required this.message,
    required this.recipientId,
    required this.chatId,
    required this.messages,
  });
}

class GetMessagesByUserId extends MessagesEvent {
  final String userId;
  GetMessagesByUserId(
    this.userId,
  );
}
