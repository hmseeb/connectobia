part of 'realtime_messaging_bloc.dart';

@immutable
sealed class RealtimeMessagingEvent {}

class SubscribeMessages extends RealtimeMessagingEvent {
  SubscribeMessages();
}

class AddNewMessage extends RealtimeMessagingEvent {
  final Message message;

  AddNewMessage(this.message);
}
