part of 'animation_cubit.dart';

final class AnimationInitial extends AnimationState {}

@immutable
sealed class AnimationState {}

final class AnimationStopped extends AnimationState {}
