part of 'realtime_messaging_bloc.dart';

class AddNewMessage extends RealtimeMessagingEvent {
  final Message message;

  AddNewMessage(this.message);
}

class GetMessagesByChatId extends RealtimeMessagingEvent {
  final String chatId;

  GetMessagesByChatId(this.chatId);
}

class GetMessagesByUserId extends RealtimeMessagingEvent {
  final String userId;
  GetMessagesByUserId(
    this.userId,
  );
}

@immutable
sealed class RealtimeMessagingEvent {}

class SendMessage extends RealtimeMessagingEvent {
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

class SubscribeMessages extends RealtimeMessagingEvent {
  SubscribeMessages();
}
