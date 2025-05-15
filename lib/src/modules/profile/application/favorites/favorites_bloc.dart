import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
    on<ClearFavorites>(_onClearFavorites);
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatus event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorite = await FavoritesRepository.isFavorite(
        userId: event.userId,
        targetUserId: event.targetUserId,
      );

      emit(FavoriteStatusChecked(
        isFavorite: isFavorite,
        targetUserId: event.targetUserId,
      ));
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      emit(FavoritesError('Failed to check favorite status: $e'));
    }
  }

  void _onClearFavorites(
    ClearFavorites event,
    Emitter<FavoritesState> emit,
  ) {
    emit(FavoritesInitial());
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites =
          await FavoritesRepository.getUserFavorites(event.userId);
      final favoriteIds = favorites.map((fav) => fav.targetUserId).toList();

      emit(FavoritesLoaded(
        favorites: favorites,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      emit(FavoritesError('Failed to load favorites: $e'));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isCurrentlyFavorite = await FavoritesRepository.toggleFavorite(
        userId: event.userId,
        targetUserId: event.targetUserId,
        userType: event.userType,
        targetUserType: event.targetUserType,
      );

      // If we already have a loaded state, update it
      if (state is FavoritesLoaded) {
        final currentState = state as FavoritesLoaded;
        List<String> updatedIds = List.from(currentState.favoriteIds);

        if (isCurrentlyFavorite) {
          // Added to favorites
          if (!updatedIds.contains(event.targetUserId)) {
            updatedIds.add(event.targetUserId);
          }
        } else {
          // Removed from favorites
          updatedIds.remove(event.targetUserId);
        }

        // Reload favorites to get the updated list
        final updatedFavorites =
            await FavoritesRepository.getUserFavorites(event.userId);

        emit(FavoritesLoaded(
          favorites: updatedFavorites,
          favoriteIds: updatedIds,
        ));
      }

      emit(FavoriteStatusChecked(
        isFavorite: isCurrentlyFavorite,
        targetUserId: event.targetUserId,
      ));
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      emit(FavoritesError('Failed to update favorite status: $e'));
    }
  }
}
