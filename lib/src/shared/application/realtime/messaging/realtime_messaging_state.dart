part of 'realtime_messaging_bloc.dart';

@immutable
sealed class RealtimeMessagingState {}

final class RealtimeMessagingInitial extends RealtimeMessagingState {}

final class RealtimeMessagingSubscribed extends RealtimeMessagingState {}

final class RealtimeMessagingError extends RealtimeMessagingState {
  final String error;

  RealtimeMessagingError(this.error);
}

final class RealtimeMessageReceived extends RealtimeMessagingState {
  final String message;

  RealtimeMessageReceived(this.message);
}
