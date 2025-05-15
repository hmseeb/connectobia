import 'package:equatable/equatable.dart';

import '../../../../shared/domain/models/favorite.dart';

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Favorite> favorites;
  final List<String> favoriteIds;

  const FavoritesLoaded({
    this.favorites = const [],
    this.favoriteIds = const [],
  });

  @override
  List<Object?> get props => [favorites, favoriteIds];
}

class FavoritesLoading extends FavoritesState {}

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoriteStatusChecked extends FavoritesState {
  final bool isFavorite;
  final String targetUserId;

  const FavoriteStatusChecked({
    required this.isFavorite,
    required this.targetUserId,
  });

  @override
  List<Object?> get props => [isFavorite, targetUserId];
}
