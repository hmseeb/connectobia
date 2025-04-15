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
                'campaign = "$campaignId" && brand = "$brandId" && influencer = "$influencerId" && role = "brand"',
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
        return review.brand == userId;
      }
      // If user is an influencer
      else {
        return review.influencer == userId;
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
        'brand': brandId,
        'influencer': influencerId,
        'campaign': campaignId,
        'rating': rating,
        'comment': comment,
        'role': 'brand',
        'submitted_at': DateTime.now().toIso8601String(),
      };

      debugPrint('Creating brand-to-influencer review with data:');
      debugPrint('  Campaign ID: $campaignId');
      debugPrint('  Brand ID: $brandId');
      debugPrint('  Influencer ID: $influencerId');
      debugPrint('  Rating: $rating');
      debugPrint('  Comment length: ${comment.length}');
      debugPrint('  Role: brand');

      // Validate that the related records exist first
      try {
        debugPrint('Verifying campaign exists...');
        final campaignRecord =
            await pb.collection('campaigns').getOne(campaignId);
        debugPrint('✅ Campaign exists: ${campaignRecord.id}');

        debugPrint('Verifying brand exists...');
        final brandRecord = await pb.collection('brands').getOne(brandId);
        debugPrint('✅ Brand exists: ${brandRecord.id}');

        debugPrint('Verifying influencer exists...');
        final influencerRecord =
            await pb.collection('influencers').getOne(influencerId);
        debugPrint('✅ Influencer exists: ${influencerRecord.id}');
      } catch (e) {
        debugPrint('❌ ERROR VALIDATING RELATIONS: $e');
        rethrow;
      }

      debugPrint('All relations verified, creating review...');
      final record = await pb.collection(_collectionName).create(body: body);
      debugPrint('✅ Review created successfully with ID: ${record.id}');
      return Review.fromRecord(record);
    } catch (e) {
      debugPrint('❌ ERROR creating brand-to-influencer review: $e');
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
        'influencer': influencerId,
        'brand': brandId,
        'campaign': campaignId,
        'rating': rating,
        'comment': comment,
        'role': 'influencer',
        'submitted_at': DateTime.now().toIso8601String(),
      };

      debugPrint('Creating influencer-to-brand review with data:');
      debugPrint('  Campaign ID: $campaignId');
      debugPrint('  Influencer ID: $influencerId');
      debugPrint('  Brand ID: $brandId');
      debugPrint('  Rating: $rating');
      debugPrint('  Comment length: ${comment.length}');
      debugPrint('  Role: influencer');

      // Validate that the related records exist first
      try {
        debugPrint('Verifying campaign exists...');
        final campaignRecord =
            await pb.collection('campaigns').getOne(campaignId);
        debugPrint('✅ Campaign exists: ${campaignRecord.id}');

        debugPrint('Verifying influencer exists...');
        final influencerRecord =
            await pb.collection('influencers').getOne(influencerId);
        debugPrint('✅ Influencer exists: ${influencerRecord.id}');

        debugPrint('Verifying brand exists...');
        final brandRecord = await pb.collection('brands').getOne(brandId);
        debugPrint('✅ Brand exists: ${brandRecord.id}');
      } catch (e) {
        debugPrint('❌ ERROR VALIDATING RELATIONS: $e');
        rethrow;
      }

      debugPrint('All relations verified, creating review...');
      final record = await pb.collection(_collectionName).create(body: body);
      debugPrint('✅ Review created successfully with ID: ${record.id}');
      return Review.fromRecord(record);
    } catch (e) {
      debugPrint('❌ ERROR creating influencer-to-brand review: $e');
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

  /// Diagnostic method to fetch all reviews, ignoring filters
  static Future<List<Review>> getAllReviews({int limit = 20}) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      debugPrint('🔍 ReviewRepository: Fetching all reviews (limit: $limit)');

      try {
        // First try with standard approach
        final resultList = await pb.collection(_collectionName).getList(
              page: 1,
              perPage: limit,
              sort: '-created',
              expand: 'campaign,brand,influencer',
            );

        debugPrint(
            '📊 ReviewRepository: Found ${resultList.items.length} reviews');

        return _processReviewRecords(resultList.items);
      } catch (e) {
        // If that fails, try without expansion which can sometimes cause issues
        debugPrint('⚠️ Error fetching with expansion: $e');
        debugPrint('   Trying without expansion...');

        final resultList = await pb.collection(_collectionName).getList(
              page: 1,
              perPage: limit,
              sort: '-created',
            );

        debugPrint(
            '📊 ReviewRepository: Found ${resultList.items.length} reviews (without expansion)');

        return _processReviewRecords(resultList.items);
      }
    } catch (e) {
      debugPrint('❌ ReviewRepository: Error getting all reviews: $e');
      return [];
    }
  }

  /// Get all reviews involving a user (as sender or recipient)
  static Future<List<Review>> getAllReviewsForUser(
      String userId, bool isBrand) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      debugPrint(
          '🔍 ReviewRepository: Fetching ALL reviews involving user $userId');

      try {
        // First try with filter approach
        String filter;
        if (isBrand) {
          // For brands:
          // - Reviews where they are the brand mentioned (regardless of role)
          filter = 'brand = "$userId"';
        } else {
          // For influencers:
          // - Reviews where they are the influencer mentioned (regardless of role)
          filter = 'influencer = "$userId"';
        }

        debugPrint('📋 ReviewRepository: Using filter: $filter');

        final resultList = await pb.collection(_collectionName).getList(
              page: 1,
              perPage: 50,
              filter: filter,
              expand: 'campaign,brand,influencer',
            );

        debugPrint(
            '📊 ReviewRepository: Received ${resultList.items.length} raw records');

        return _processReviewRecords(resultList.items);
      } catch (e) {
        // If filtering fails, get all reviews and filter manually
        debugPrint('⚠️ Error fetching with filter: $e');
        debugPrint('   Trying alternative approach...');

        final resultList = await pb.collection(_collectionName).getList(
              page: 1,
              perPage: 100,
              expand: 'campaign,brand,influencer',
            );

        debugPrint(
            '📊 ReviewRepository: Received ${resultList.items.length} raw records (without filter)');

        // Filter manually
        final List<Review> allReviews = _processReviewRecords(resultList.items);
        final List<Review> userReviews = [];

        for (var review in allReviews) {
          bool isInvolved = false;

          if (isBrand) {
            if (review.brand == userId) {
              isInvolved = true;
            }
          } else {
            if (review.influencer == userId) {
              isInvolved = true;
            }
          }

          if (isInvolved) {
            userReviews.add(review);
            debugPrint('✅ Found review involving user: ${review.id}');
            debugPrint('   Brand: ${review.brand}');
            debugPrint('   Influencer: ${review.influencer}');
            debugPrint('   Role: ${review.role}');
          }
        }

        debugPrint(
            '✓ ReviewRepository: Found ${userReviews.length} reviews involving this user');
        return userReviews;
      }
    } catch (e) {
      debugPrint('❌ ReviewRepository: Error getting reviews for user: $e');
      return [];
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

  /// Diagnostic method to directly fetch a review by ID
  static Future<Review?> getReviewById(String reviewId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      debugPrint('🔍 ReviewRepository: Fetching review with ID: $reviewId');

      final record = await pb.collection(_collectionName).getOne(
            reviewId,
            expand: 'campaign,brand,influencer',
          );

      debugPrint('✓ ReviewRepository: Found review: ${record.id}');
      debugPrint('   Review data: ${record.data}');

      try {
        final review = Review.fromRecord(record);
        return review;
      } catch (e) {
        debugPrint('⚠️ ReviewRepository: Error parsing review: $e');
        return null;
      }
    } catch (e) {
      debugPrint('❌ ReviewRepository: Error fetching review by ID: $e');
      return null;
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
            expand: 'campaign,brand,influencer',
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

      // Get reviews where:
      // 1. The brand is the brandId AND
      // 2. The review was given by an influencer (role = "influencer")
      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'brand = "$brandId" && role = "influencer"',
            expand: 'campaign,influencer',
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

      // Get reviews where:
      // 1. The influencer is the influencerId AND
      // 2. The review was given by a brand (role = "brand")
      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'influencer = "$influencerId" && role = "brand"',
            expand: 'campaign,brand',
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
                'campaign = "$campaignId" && influencer = "$influencerId" && brand = "$brandId" && role = "influencer"',
          );

      return resultList.items.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if influencer review exists: $e');
      return false;
    }
  }

  /// Helper method to process review records
  static List<Review> _processReviewRecords(List<dynamic> records) {
    final List<Review> reviews = [];

    for (var record in records) {
      try {
        final review = Review.fromRecord(record);
        reviews.add(review);

        debugPrint('✓ Review ID: ${review.id}');
        debugPrint('  Brand: ${review.brand}');
        debugPrint('  Influencer: ${review.influencer}');
        debugPrint('  Role: ${review.role}');
        debugPrint('  Rating: ${review.rating}');
        debugPrint('  Comment: ${review.comment}');
        debugPrint('  Date: ${review.submittedAt}');
      } catch (e) {
        debugPrint('⚠️ Error parsing review: $e');
        debugPrint('   Record data: ${record.data}');
      }
    }

    return reviews;
  }
}
