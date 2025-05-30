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

class SendMedia extends RealtimeMessagingEvent {
  final String path;
  final String fileName;
  final String recipientId;
  final String chatId;
  final Messages messages;

  SendMedia({
    required this.path,
    required this.fileName,
    required this.recipientId,
    required this.messages,
    required this.chatId,
  });
}

class SendMessageNotification extends RealtimeMessagingEvent {
  // callback function to be called when the notification is sent
  final Function() sendNotification;
  SendMessageNotification({required this.sendNotification});
}

class SendTextMessage extends RealtimeMessagingEvent {
  final String recipientId;
  final String message;
  final String chatId;
  final Messages messages;
  final String messageType;

  SendTextMessage({
    required this.message,
    required this.recipientId,
    required this.chatId,
    required this.messages,
    required this.messageType,
  });
}

class SubscribeMessages extends RealtimeMessagingEvent {
  SubscribeMessages();
}

class UnsubscribeMessages extends RealtimeMessagingEvent {
  UnsubscribeMessages();
}
