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

      debugPrint('Checking if brand review exists with:');
      debugPrint('  Campaign ID: $campaignId');
      debugPrint('  Brand ID: $brandId');
      debugPrint('  Influencer ID: $influencerId');

      // Validate that brand and influencer IDs are not the same
      if (brandId == influencerId) {
        debugPrint(
            '⚠️ Warning: Brand and influencer IDs are the same. This is invalid.');
        return false;
      }

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 1,
            filter:
                'campaign = "$campaignId" AND brand = "$brandId" AND influencer = "$influencerId" AND role = "brand"',
          );

      final exists = resultList.items.isNotEmpty;
      debugPrint('Brand review exists: $exists');
      return exists;
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

      debugPrint('Creating brand-to-influencer review with data:');
      debugPrint('  Campaign ID: $campaignId');
      debugPrint('  Brand ID: $brandId');
      debugPrint('  Influencer ID: $influencerId');
      debugPrint('  Rating: $rating');
      debugPrint('  Comment length: ${comment.length}');
      debugPrint('  Role: brand');

      // Check if IDs might be swapped (if brandId is actually an influencerId)
      bool idsSwapped = false;
      String actualBrandId = brandId;
      String actualInfluencerId = influencerId;

      try {
        debugPrint('Checking if brand ID exists in influencers collection...');
        await pb.collection('influencers').getOne(brandId);
        debugPrint(
            'WARNING: Brand ID exists as an influencer! IDs might be swapped.');

        try {
          debugPrint(
              'Checking if influencer ID exists in brands collection...');
          await pb.collection('brands').getOne(influencerId);
          debugPrint(
              'Influencer ID exists as a brand. Swapping IDs for review creation.');

          // Swap the IDs
          actualBrandId = influencerId;
          actualInfluencerId = brandId;
          idsSwapped = true;

          debugPrint('CORRECTION: Using actual brand ID: $actualBrandId');
          debugPrint(
              'CORRECTION: Using actual influencer ID: $actualInfluencerId');
        } catch (e) {
          debugPrint(
              'Influencer ID does not exist as a brand. Not swapping IDs.');
        }
      } catch (e) {
        debugPrint('Brand ID is correctly a brand. IDs are correct.');
      }

      // Create the review with potentially swapped IDs
      final body = {
        'brand': actualBrandId,
        'influencer': actualInfluencerId,
        'campaign': campaignId,
        'rating': rating,
        'comment': comment,
        'role': 'brand',
        'submitted_at': DateTime.now().toIso8601String(),
      };

      // Validate that the related records exist first
      try {
        debugPrint('Verifying campaign exists...');
        bool allRecordsExist = true;
        String errorMessage = '';

        try {
          final campaignRecord =
              await pb.collection('campaigns').getOne(campaignId);
          debugPrint('✅ Campaign exists: ${campaignRecord.id}');
        } catch (e) {
          allRecordsExist = false;
          errorMessage = 'Campaign not found';
          debugPrint('❌ Campaign not found: $e');
        }

        bool brandExists = false;
        try {
          debugPrint('Verifying brand exists...');
          final brandRecord =
              await pb.collection('brands').getOne(actualBrandId);
          debugPrint('✅ Brand exists: ${brandRecord.id}');
          brandExists = true;
        } catch (e) {
          debugPrint('❌ Brand not found: $e');
        }

        bool influencerExists = false;
        try {
          debugPrint('Verifying influencer exists...');
          final influencerRecord =
              await pb.collection('influencers').getOne(actualInfluencerId);
          debugPrint('✅ Influencer exists: ${influencerRecord.id}');
          influencerExists = true;
        } catch (e) {
          debugPrint('❌ Influencer not found: $e');
        }

        if (!brandExists) {
          allRecordsExist = false;
          errorMessage =
              'Brand account not found. The user might have been deleted.';
        }

        if (!influencerExists) {
          allRecordsExist = false;
          errorMessage =
              'Influencer account not found. The user might have been deleted.';
        }

        if (!allRecordsExist) {
          throw Exception('Cannot create review: $errorMessage');
        }
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

      debugPrint('Creating influencer-to-brand review with data:');
      debugPrint('  Campaign ID: $campaignId');
      debugPrint('  Influencer ID: $influencerId');
      debugPrint('  Brand ID: $brandId');
      debugPrint('  Rating: $rating');
      debugPrint('  Comment length: ${comment.length}');
      debugPrint('  Role: influencer');

      // If the influencer ID and brand ID are the same, this is definitely an error
      if (influencerId == brandId) {
        debugPrint(
            '⚠️ ERROR: influencerId and brandId are the same! This is invalid.');
        throw Exception(
            'Cannot create review: The same ID cannot be used for both brand and influencer');
      }

      // Check if IDs might be swapped (if influencerId is actually a brandId)
      bool idsSwapped = false;
      String actualInfluencerId = influencerId;
      String actualBrandId = brandId;

      // First check which collection the influencerId belongs to
      String influencerCollection = '';
      try {
        await pb.collection('influencers').getOne(influencerId);
        influencerCollection = 'influencers';
        debugPrint('✅ Confirmed influencerId exists in influencers collection');
      } catch (e) {
        try {
          await pb.collection('brands').getOne(influencerId);
          influencerCollection = 'brands';
          debugPrint('⚠️ WARNING: influencerId exists in brands collection!');
        } catch (e2) {
          debugPrint('❌ influencerId not found in any collection!');
        }
      }

      // Then check which collection the brandId belongs to
      String brandCollection = '';
      try {
        await pb.collection('brands').getOne(brandId);
        brandCollection = 'brands';
        debugPrint('✅ Confirmed brandId exists in brands collection');
      } catch (e) {
        try {
          await pb.collection('influencers').getOne(brandId);
          brandCollection = 'influencers';
          debugPrint('⚠️ WARNING: brandId exists in influencers collection!');
        } catch (e2) {
          debugPrint('❌ brandId not found in any collection!');
        }
      }

      // Determine if we need to swap IDs
      if (influencerCollection == 'brands' &&
          brandCollection == 'influencers') {
        debugPrint(
            '🔄 SWAPPING IDs: influencer and brand IDs appear to be reversed');
        actualInfluencerId = brandId;
        actualBrandId = influencerId;
        idsSwapped = true;
      } else if (influencerCollection != 'influencers') {
        debugPrint('❌ ERROR: influencerId is not a valid influencer');
      } else if (brandCollection != 'brands') {
        debugPrint('❌ ERROR: brandId is not a valid brand');
      }

      debugPrint('Using final IDs:');
      debugPrint('  Final Influencer ID: $actualInfluencerId');
      debugPrint('  Final Brand ID: $actualBrandId');
      debugPrint('  IDs were swapped: $idsSwapped');

      // Create the review with potentially swapped IDs
      final body = {
        'influencer': actualInfluencerId,
        'brand': actualBrandId,
        'campaign': campaignId,
        'rating': rating,
        'comment': comment,
        'role': 'influencer',
        'submitted_at': DateTime.now().toIso8601String(),
      };

      // Validate that the related records exist first
      try {
        debugPrint('Verifying campaign exists...');
        bool allRecordsExist = true;
        String errorMessage = '';

        try {
          final campaignRecord =
              await pb.collection('campaigns').getOne(campaignId);
          debugPrint('✅ Campaign exists: ${campaignRecord.id}');
        } catch (e) {
          allRecordsExist = false;
          errorMessage = 'Campaign not found';
          debugPrint('❌ Campaign not found: $e');
        }

        bool influencerExists = false;
        try {
          debugPrint('Verifying influencer exists...');
          final influencerRecord =
              await pb.collection('influencers').getOne(actualInfluencerId);
          debugPrint('✅ Influencer exists: ${influencerRecord.id}');
          influencerExists = true;
        } catch (e) {
          debugPrint('❌ Influencer not found: $e');
        }

        bool brandExists = false;
        try {
          debugPrint('Verifying brand exists...');
          final brandRecord =
              await pb.collection('brands').getOne(actualBrandId);
          debugPrint('✅ Brand exists: ${brandRecord.id}');
          brandExists = true;
        } catch (e) {
          debugPrint('❌ Brand not found: $e');
        }

        if (!influencerExists) {
          allRecordsExist = false;
          errorMessage =
              'Influencer account not found. The user might have been deleted.';
        }

        if (!brandExists) {
          allRecordsExist = false;
          errorMessage =
              'Brand account not found. The user might have been deleted.';
        }

        if (!allRecordsExist) {
          throw Exception('Cannot create review: $errorMessage');
        }
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

      debugPrint('Checking if influencer review exists with:');
      debugPrint('  Campaign ID: $campaignId');
      debugPrint('  Influencer ID: $influencerId');
      debugPrint('  Brand ID: $brandId');

      // Validate that brand and influencer IDs are not the same
      if (brandId == influencerId) {
        debugPrint(
            '⚠️ Warning: Brand and influencer IDs are the same. This is invalid.');
        return false;
      }

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 1,
            filter:
                'campaign = "$campaignId" AND influencer = "$influencerId" AND brand = "$brandId" AND role = "influencer"',
          );

      final exists = resultList.items.isNotEmpty;
      debugPrint('Influencer review exists: $exists');
      return exists;
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
