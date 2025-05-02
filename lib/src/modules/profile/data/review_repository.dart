import 'package:flutter/material.dart';

import '../../../../src/services/storage/pb.dart';
import '../../../../src/shared/data/repositories/error_repo.dart';
import '../../../../src/shared/domain/models/review.dart';

class ReviewRepository {
  static const String _collectionName = 'reviews';

  /// Check if a review from brand to influencer exists for a campaign
  static Future<bool> brandReviewExists({
    required String campaignId,
    required String brandId,
    required String influencerId,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 1,
            filter:
                'campaign = "$campaignId" && from_brand = "$brandId" && to_influencer = "$influencerId"',
          );

      return resultList.items.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if brand review exists: $e');
      return false;
    }
  }

  /// Check if a user can delete a review
  /// Users can delete reviews they've written or received
  static Future<bool> canUserDeleteReview(
      {required String userId,
      required bool isBrand,
      required Review review}) async {
    try {
      // If user is a brand
      if (isBrand) {
        // Brand can delete reviews they wrote or received
        return (review.fromBrand == userId || review.toBrand == userId);
      }
      // If user is an influencer
      else {
        // Influencer can delete reviews they wrote or received
        return (review.fromInfluencer == userId ||
            review.toInfluencer == userId);
      }
    } catch (e) {
      debugPrint('Error checking if user can delete review: $e');
      return false;
    }
  }

  /// Create a brand-to-influencer review
  static Future<Review> createBrandToInfluencerReview({
    required String campaignId,
    required String brandId,
    required String influencerId,
    required int rating,
    required String comment,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      // Create the review
      final body = {
        'from_brand': brandId,
        'to_influencer': influencerId,
        'campaign': campaignId,
        'rating': rating,
        'comment': comment,
        'role': 'brand',
        'submitted_at': DateTime.now().toIso8601String(),
      };

      debugPrint('Creating brand-to-influencer review: $body');

      final record = await pb.collection(_collectionName).create(body: body);
      return Review.fromRecord(record);
    } catch (e) {
      debugPrint('Error creating brand-to-influencer review: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Create an influencer-to-brand review
  static Future<Review> createInfluencerToBrandReview({
    required String campaignId,
    required String influencerId,
    required String brandId,
    required int rating,
    required String comment,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      // Create the review
      final body = {
        'from_influencer': influencerId,
        'to_brand': brandId,
        'campaign': campaignId,
        'rating': rating,
        'comment': comment,
        'role': 'influencer',
        'submitted_at': DateTime.now().toIso8601String(),
      };

      debugPrint('Creating influencer-to-brand review: $body');

      final record = await pb.collection(_collectionName).create(body: body);
      return Review.fromRecord(record);
    } catch (e) {
      debugPrint('Error creating influencer-to-brand review: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Delete a review by its ID
  static Future<bool> deleteReview(String reviewId) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      await pb.collection(_collectionName).delete(reviewId);
      return true;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get average rating for a brand
  static Future<double> getBrandAverageRating(String brandId) async {
    try {
      final reviews = await getReviewsForBrand(brandId);

      if (reviews.isEmpty) {
        return 0.0;
      }

      final total = reviews.fold(0, (sum, review) => sum + review.rating);
      return total / reviews.length;
    } catch (e) {
      debugPrint('Error getting brand average rating: $e');
      return 0.0;
    }
  }

  /// Get average rating for an influencer
  static Future<double> getInfluencerAverageRating(String influencerId) async {
    try {
      final reviews = await getReviewsForInfluencer(influencerId);

      if (reviews.isEmpty) {
        return 0.0;
      }

      final total = reviews.fold(0, (sum, review) => sum + review.rating);
      return total / reviews.length;
    } catch (e) {
      debugPrint('Error getting influencer average rating: $e');
      return 0.0;
    }
  }

  /// Get all reviews for a campaign
  static Future<List<Review>> getReviewsByCampaignId(String campaignId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'campaign = "$campaignId"',
            expand:
                'campaign,from_brand,to_influencer,from_influencer,to_brand',
          );

      return resultList.items
          .map((record) => Review.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('Error getting reviews by campaign ID: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get all reviews for a brand (reviews the brand has received)
  static Future<List<Review>> getReviewsForBrand(String brandId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'to_brand = "$brandId"',
            expand: 'campaign,from_influencer',
          );

      return resultList.items
          .map((record) => Review.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('Error getting reviews for brand: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get all reviews for an influencer (reviews the influencer has received)
  static Future<List<Review>> getReviewsForInfluencer(
      String influencerId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'to_influencer = "$influencerId"',
            expand: 'campaign,from_brand',
          );

      return resultList.items
          .map((record) => Review.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('Error getting reviews for influencer: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Check if a review from influencer to brand exists for a campaign
  static Future<bool> influencerReviewExists({
    required String campaignId,
    required String influencerId,
    required String brandId,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 1,
            filter:
                'campaign = "$campaignId" && from_influencer = "$influencerId" && to_brand = "$brandId"',
          );

      return resultList.items.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if influencer review exists: $e');
      return false;
    }
  }
}
