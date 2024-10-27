part of 'subscription_bloc.dart';

@immutable
sealed class SubscriptionEvent {}

final class UserCreateEvent extends SubscriptionEvent {}

final class UserDeleteEvent extends SubscriptionEvent {}

final class UserInitialEvent extends SubscriptionEvent {}

final class UserUpdateEvent extends SubscriptionEvent {}
