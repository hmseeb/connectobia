import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../modules/profile/data/favorites_repository.dart';
import '../../../../../services/storage/pb.dart';
import '../../../../../shared/application/theme/theme_bloc.dart';
import '../../../../../theme/colors.dart';

class FeatureHeartIcon extends StatefulWidget {
  final String targetUserId;
  final String targetUserType;
  final bool initialFavorite;
  final Function(bool isFavorite)? onToggle;

  const FeatureHeartIcon({
    super.key,
    required this.targetUserId,
    required this.targetUserType,
    this.initialFavorite = false,
    this.onToggle,
  });

  @override
  State<FeatureHeartIcon> createState() => _FeatureHeartIconState();
}

class _FeatureHeartIconState extends State<FeatureHeartIcon> {
  bool _isFavorite = false;
  bool _isLoading = false;
  double _iconScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDark = state is DarkTheme;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? ShadColors.dark.withOpacity(0.7)
                  : ShadColors.light.withOpacity(0.7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: _isLoading ? null : _toggleFavorite,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: Skeletonizer(
                            enabled: true,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        )
                      : AnimatedScale(
                          scale: _iconScale,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.elasticOut,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey(_isFavorite),
                              color: _isFavorite
                                  ? Colors.red
                                  : (isDark
                                      ? ShadColors.light
                                      : ShadColors.dark),
                              size: 24,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialFavorite;
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final currentUserId = pb.authStore.model.id;

      setState(() {
        _isLoading = true;
      });

      final isFavorite = await FavoritesRepository.isFavorite(
        userId: currentUserId,
        targetUserId: widget.targetUserId,
      );

      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final currentUserId = pb.authStore.model.id;
      final userType = pb.authStore.model.collectionId;

      setState(() {
        _isLoading = true;
      });

      final isFavorite = await FavoritesRepository.toggleFavorite(
        userId: currentUserId,
        targetUserId: widget.targetUserId,
        userType: userType,
        targetUserType: widget.targetUserType,
      );

      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isLoading = false;
        });

        // Run animation
        setState(() {
          _iconScale = 1.4;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _iconScale = 1.0;
            });
          }
        });

        if (widget.onToggle != null) {
          widget.onToggle!(_isFavorite);
        }
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
