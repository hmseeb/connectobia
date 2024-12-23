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
  final Message message;
  final String avatar;
  final String name;
  final String userId;
  final String collectionId;

  RealtimeMessageReceived({
    required this.message,
    required this.avatar,
    required this.name,
    required this.userId,
    required this.collectionId,
  });
}
