part of 'subscription_bloc.dart';

// email verified state
final class EmailVerifiedState extends SubscriptionState {}

final class SubscriptionInitial extends SubscriptionState {}

@immutable
sealed class SubscriptionState {}

final class UserCreateState extends SubscriptionState {
  final RecordSubscriptionEvent event;

  UserCreateState(this.event);
}

final class UserDeleteState extends SubscriptionState {
  final RecordSubscriptionEvent event;

  UserDeleteState(this.event);
}

final class UserUpdateState extends SubscriptionState {
  final RecordSubscriptionEvent event;

  UserUpdateState(this.event);
}
