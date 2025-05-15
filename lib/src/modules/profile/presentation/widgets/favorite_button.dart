import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../application/favorites/favorites_bloc.dart';
import '../../application/favorites/favorites_event.dart';
import '../../application/favorites/favorites_state.dart';

/// A button widget for toggling favorite status of an influencer or brand
class FavoriteButton extends StatefulWidget {
  /// The user to favorite (target user)
  final dynamic targetUser;

  /// The current user ID
  final String currentUserId;

  /// The current user type (influencer/brand)
  final String currentUserType;

  /// Optional size for the icon
  final double size;

  /// Whether to show a filled icon even before checking the status
  final bool initiallyFilled;

  /// Optional callback when favorite status changes
  final Function(bool isFavorite)? onFavoriteChanged;

  const FavoriteButton({
    super.key,
    required this.targetUser,
    required this.currentUserId,
    required this.currentUserType,
    this.size = 24.0,
    this.initiallyFilled = false,
    this.onFavoriteChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        if (state is FavoriteStatusChecked) {
          final String targetUserId = _getTargetUserId();

          // Only update if this status check is for our target user
          if (state.targetUserId == targetUserId) {
            setState(() {
              _isFavorite = state.isFavorite;
              _isLoading = false;
            });

            // Notify parent if callback provided
            widget.onFavoriteChanged?.call(state.isFavorite);
          }
        }
      },
      child: IconButton(
        icon: _isLoading
            ? SizedBox(
                width: widget.size,
                height: widget.size,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
              )
            : Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
                size: widget.size,
              ),
        onPressed: _isLoading ? null : _toggleFavorite,
        tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
      ),
    );
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check favorite status again if the target user changed
    if (oldWidget.targetUser != widget.targetUser) {
      _checkFavoriteStatus();
    }
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initiallyFilled;

    // Check favorite status when widget initializes
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() {
    final String targetUserId = _getTargetUserId();

    if (targetUserId.isNotEmpty && widget.currentUserId.isNotEmpty) {
      context.read<FavoritesBloc>().add(CheckFavoriteStatus(
            userId: widget.currentUserId,
            targetUserId: targetUserId,
          ));
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getTargetUserId() {
    if (widget.targetUser is Brand) {
      return (widget.targetUser as Brand).id;
    } else if (widget.targetUser is Influencer) {
      return (widget.targetUser as Influencer).id;
    }
    return '';
  }

  String _getTargetUserType() {
    if (widget.targetUser is Brand) {
      return 'brand';
    } else if (widget.targetUser is Influencer) {
      return 'influencer';
    }
    return '';
  }

  void _toggleFavorite() {
    final String targetUserId = _getTargetUserId();
    final String targetUserType = _getTargetUserType();

    if (targetUserId.isEmpty || widget.currentUserId.isEmpty) {
      return;
    }

    context.read<FavoritesBloc>().add(ToggleFavorite(
          userId: widget.currentUserId,
          targetUserId: targetUserId,
          userType: widget.currentUserType,
          targetUserType: targetUserType,
        ));
  }
}
