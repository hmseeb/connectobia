import 'package:flutter/foundation.dart';

import '../../../services/storage/pb.dart';
import '../../../shared/domain/models/favorite.dart';

/// Repository for managing favorites
class FavoritesRepository {
  static const String _collection = 'favorites';

  /// Add a user to favorites
  static Future<Favorite> addFavorite({
    required String userId,
    required String targetUserId,
    required String userType,
    required String targetUserType,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      // Create new favorite entry
      final record = await pb.collection(_collection).create(body: {
        'user_id': userId,
        'target_user_id': targetUserId,
        'user_type': userType,
        'target_user_type': targetUserType,
      });

      return Favorite.fromJson(record.toJson());
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      rethrow;
    }
  }

  /// Get favorite by user ID and target user ID
  static Future<Favorite?> getFavorite({
    required String userId,
    required String targetUserId,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final result = await pb.collection(_collection).getList(
            filter: 'user_id = "$userId" && target_user_id = "$targetUserId"',
            page: 1,
            perPage: 1,
          );

      if (result.items.isEmpty) {
        return null;
      }

      return Favorite.fromJson(result.items.first.toJson());
    } catch (e) {
      debugPrint('Error getting favorite: $e');
      return null;
    }
  }

  /// Get all favorite IDs for a user (just the target user IDs)
  static Future<List<String>> getUserFavoriteIds(String userId) async {
    try {
      final favorites = await getUserFavorites(userId);
      return favorites.map((fav) => fav.targetUserId).toList();
    } catch (e) {
      debugPrint('Error getting user favorite IDs: $e');
      return [];
    }
  }

  /// Get all favorites for a user
  static Future<List<Favorite>> getUserFavorites(String userId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final result = await pb.collection(_collection).getList(
            filter: 'user_id = "$userId"',
            sort: '-created',
          );

      return result.items
          .map((item) => Favorite.fromJson(item.toJson()))
          .toList();
    } catch (e) {
      debugPrint('Error getting user favorites: $e');
      return [];
    }
  }

  /// Check if a user is favorited
  static Future<bool> isFavorite({
    required String userId,
    required String targetUserId,
  }) async {
    final favorite = await getFavorite(
      userId: userId,
      targetUserId: targetUserId,
    );
    return favorite != null;
  }

  /// Remove a user from favorites
  static Future<void> removeFavorite(String favoriteId) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      await pb.collection(_collection).delete(favoriteId);
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      rethrow;
    }
  }

  /// Toggle favorite status
  static Future<bool> toggleFavorite({
    required String userId,
    required String targetUserId,
    required String userType,
    required String targetUserType,
  }) async {
    try {
      final favorite = await getFavorite(
        userId: userId,
        targetUserId: targetUserId,
      );

      if (favorite != null) {
        await removeFavorite(favorite.id);
        return false; // Removed from favorites
      } else {
        await addFavorite(
          userId: userId,
          targetUserId: targetUserId,
          userType: userType,
          targetUserType: targetUserType,
        );
        return true; // Added to favorites
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }
}
