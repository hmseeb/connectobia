import 'package:equatable/equatable.dart';

/// Represents a favorite/bookmark relationship between users
/// A user can mark another user (influencer or brand) as favorite/bookmarked
class Favorite extends Equatable {
  final String id;
  final String userId;
  final String targetUserId;
  final String userType;
  final String targetUserType;
  final DateTime created;
  final DateTime updated;

  const Favorite({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.userType,
    required this.targetUserType,
    required this.created,
    required this.updated,
  });

  /// Create a Favorite from PocketBase JSON map
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['user_id'],
      targetUserId: json['target_user_id'],
      userType: json['user_type'],
      targetUserType: json['target_user_type'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        targetUserId,
        userType,
        targetUserType,
        created,
        updated,
      ];

  /// Convert to JSON map for PocketBase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_user_id': targetUserId,
      'user_type': userType,
      'target_user_type': targetUserType,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }
}
