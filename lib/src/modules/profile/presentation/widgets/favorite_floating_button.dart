import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/domain/models/brand.dart';
import '../../application/favorites/favorites_bloc.dart';
import '../../application/favorites/favorites_event.dart';
import '../../application/favorites/favorites_state.dart';

/// A floating action button that shows favorite status
class FavoriteFloatingButton extends StatelessWidget {
  final dynamic targetUser;
  final dynamic currentUser;

  const FavoriteFloatingButton({
    super.key,
    required this.targetUser,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final String currentUserId = currentUser.id;
    final String currentUserType =
        currentUser is Brand ? 'brand' : 'influencer';

    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        // Initialize with default values
        bool isFavorite = false;
        bool isLoading = true;

        // Update based on state
        if (state is FavoriteStatusChecked &&
            state.targetUserId ==
                (targetUser is Brand ? targetUser.id : targetUser.id)) {
          isFavorite = state.isFavorite;
          isLoading = false;
        } else if (state is FavoritesLoaded) {
          isFavorite = state.favoriteIds
              .contains(targetUser is Brand ? targetUser.id : targetUser.id);
          isLoading = false;
        }

        // Check favorite status when widget first builds
        if (isLoading) {
          context.read<FavoritesBloc>().add(CheckFavoriteStatus(
                userId: currentUserId,
                targetUserId:
                    targetUser is Brand ? targetUser.id : targetUser.id,
              ));
        }

        return FloatingActionButton(
          heroTag: 'favorite-button',
          backgroundColor: isFavorite ? Colors.red : Colors.white,
          elevation: 6.0,
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          onPressed: () {
            final String targetUserId =
                targetUser is Brand ? targetUser.id : targetUser.id;
            final String targetUserType =
                targetUser is Brand ? 'brand' : 'influencer';

            context.read<FavoritesBloc>().add(ToggleFavorite(
                  userId: currentUserId,
                  targetUserId: targetUserId,
                  userType: currentUserType,
                  targetUserType: targetUserType,
                ));
          },
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.grey,
                  ),
                )
              : Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.white : Colors.red,
                  size: 28,
                ),
        );
      },
    );
  }
}
