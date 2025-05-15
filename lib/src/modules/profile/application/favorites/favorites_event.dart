import 'package:equatable/equatable.dart';

class CheckFavoriteStatus extends FavoritesEvent {
  final String userId;
  final String targetUserId;

  const CheckFavoriteStatus({
    required this.userId,
    required this.targetUserId,
  });

  @override
  List<Object?> get props => [userId, targetUserId];
}

class ClearFavorites extends FavoritesEvent {}

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {
  final String userId;

  const LoadFavorites(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ToggleFavorite extends FavoritesEvent {
  final String userId;
  final String targetUserId;
  final String userType;
  final String targetUserType;

  const ToggleFavorite({
    required this.userId,
    required this.targetUserId,
    required this.userType,
    required this.targetUserType,
  });

  @override
  List<Object?> get props => [userId, targetUserId, userType, targetUserType];
}
