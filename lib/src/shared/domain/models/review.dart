import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

class Review {
  final String id;
  final String collectionId;
  final String collectionName;
  final String brand;
  final String influencer;
  final String campaign;
  final int rating;
  final String comment;
  final String
      role; // 'brand' if brand gave review, 'influencer' if influencer gave review
  final DateTime submittedAt;
  final DateTime created;
  final DateTime updated;

  // Optional expanded records
  final dynamic campaignRecord;
  final dynamic brandRecord;
  final dynamic influencerRecord;

  Review({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.brand,
    required this.influencer,
    required this.campaign,
    required this.rating,
    required this.comment,
    required this.role,
    required this.submittedAt,
    required this.created,
    required this.updated,
    this.campaignRecord,
    this.brandRecord,
    this.influencerRecord,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    try {
      return Review(
        id: json['id'] ?? '',
        collectionId: json['collectionId'] ?? '',
        collectionName: json['collectionName'] ?? '',
        brand: json['brand'] ?? '',
        influencer: json['influencer'] ?? '',
        campaign: json['campaign'] ?? '',
        rating: _parseRating(json['rating']),
        comment: json['comment'] ?? '',
        role: json['role'] ?? '',
        submittedAt: _parseDateTime(json['submitted_at']),
        created: _parseDateTime(json['created']),
        updated: _parseDateTime(json['updated']),
        campaignRecord: json['expand']?['campaign'],
        brandRecord: json['expand']?['brand'],
        influencerRecord: json['expand']?['influencer'],
      );
    } catch (e) {
      debugPrint('❌ Error parsing Review from JSON: $e');
      rethrow;
    }
  }

  factory Review.fromRawJson(String str) => Review.fromJson(json.decode(str));

  factory Review.fromRecord(RecordModel record) {
    try {
      return Review(
        id: record.id,
        collectionId: record.collectionId,
        collectionName: record.collectionName,
        brand: record.data['brand'] ?? '',
        influencer: record.data['influencer'] ?? '',
        campaign: record.data['campaign'] ?? '',
        rating: _parseRating(record.data['rating']),
        comment: record.data['comment'] ?? '',
        role: record.data['role'] ?? '',
        submittedAt: _parseDateTime(record.data['submitted_at']),
        created: _parseDateTime(record.created),
        updated: _parseDateTime(record.updated),
        campaignRecord: record.expand['campaign'],
        brandRecord: record.expand['brand'],
        influencerRecord: record.expand['influencer'],
      );
    } catch (e) {
      debugPrint('❌ Error parsing Review from Record: $e');
      debugPrint('Record data: ${record.data}');
      rethrow;
    }
  }

  // Helper getter for the reviewer ID
  String get fromId => isBrandReviewer ? brand : influencer;

  // Helper getter to determine if the brand is the reviewer
  bool get isBrandReviewer => role == 'brand';

  // Helper getter to determine if the influencer is the reviewer
  bool get isInfluencerReviewer => role == 'influencer';

  // Helper getter for the reviewed ID
  String get toId => isBrandReviewer ? influencer : brand;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'brand': brand,
      'influencer': influencer,
      'campaign': campaign,
      'rating': rating,
      'comment': comment,
      'role': role,
      'submitted_at': submittedAt.toIso8601String(),
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  String toRawJson() => json.encode(toJson());

  // Helper method to safely parse DateTime values
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }

    if (dateValue is DateTime) {
      return dateValue;
    }

    if (dateValue is String) {
      try {
        // Try standard ISO format
        return DateTime.parse(dateValue);
      } catch (_) {
        // If that fails, try alternative formats
        try {
          // Try format with space instead of T
          // e.g. "2022-01-01 10:00:00.123Z" instead of "2022-01-01T10:00:00.123Z"
          final fixedDate = dateValue.replaceAll(' ', 'T');
          return DateTime.parse(fixedDate);
        } catch (_) {
          // Default to current time if all parsing fails
          return DateTime.now();
        }
      }
    }

    // Default fallback
    return DateTime.now();
  }

  // Helper method to safely parse rating values
  static int _parseRating(dynamic ratingValue) {
    if (ratingValue == null) return 5;

    if (ratingValue is int) return ratingValue;

    // Handle string ratings
    if (ratingValue is String) {
      // Try int.parse first
      try {
        return int.parse(ratingValue);
      } catch (_) {}

      // Try double.parse then convert to int
      try {
        return double.parse(ratingValue).round();
      } catch (_) {}
    }

    // Handle double ratings
    if (ratingValue is double) {
      return ratingValue.round();
    }

    // Default to 5 if parsing fails
    return 5;
  }
}
