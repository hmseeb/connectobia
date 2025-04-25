import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/constants/industries.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:flutter/material.dart';

class CampaignRepository {
  static const String _collectionName = 'campaigns';

  /// Assign influencer to campaign
  static Future<Campaign> assignInfluencer(
      String campaignId, String influencerId) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final record = await pb.collection(_collectionName).update(campaignId,
          body: {'selected_influencer': influencerId, 'status': 'assigned'});
      return Campaign.fromRecord(record);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Create a new campaign
  static Future<Campaign> createCampaign(Campaign campaign) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.record!.id;

      // Make sure the brand is set to the current user
      final body = campaign.copyWith(brand: userId).toCreateJson();

      final record = await pb.collection(_collectionName).create(body: body);
      return Campaign.fromRecord(record);
    } catch (e) {
      debugPrint('Error creating campaign: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Delete a campaign
  static Future<void> deleteCampaign(String id) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      await pb.collection(_collectionName).delete(id);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get campaigns assigned to a specific influencer
  static Future<List<Campaign>> getAssignedCampaigns() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'selected_influencer = "$userId"',
          );

      List<Campaign> campaigns = resultList.items.map((record) {
        return Campaign.fromRecord(record);
      }).toList();

      return campaigns;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get all campaigns available for an influencer
  static Future<List<Campaign>> getAvailableCampaigns() async {
    try {
      final pb = await PocketBaseSingleton.instance;

      // First, let's debug by getting all campaigns to see what's there
      final allCampaigns = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
          );

      debugPrint(
          'DEBUG: Total campaigns in database: ${allCampaigns.items.length}');
      for (var item in allCampaigns.items) {
        debugPrint(
            'Campaign: ${item.id}, Status: ${item.data['status']}, Influencer: ${item.data['selected_influencer']}');
      }

      // Now the actual query with improved filter
      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter:
                'status = "active" && (selected_influencer = "" || selected_influencer = null)',
          );

      debugPrint(
          'DEBUG: Available campaigns found: ${resultList.items.length}');

      List<Campaign> campaigns = resultList.items.map((record) {
        return Campaign.fromRecord(record);
      }).toList();

      return campaigns;
    } catch (e) {
      debugPrint('Error fetching available campaigns: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get a campaign by ID
  static Future<Campaign> getCampaignById(String id) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final record = await pb.collection(_collectionName).getOne(id);
      return Campaign.fromRecord(record);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get all campaigns for the logged-in brand
  static Future<List<Campaign>> getCampaigns() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'brand = "$userId"',
          );

      List<Campaign> campaigns = resultList.items.map((record) {
        return Campaign.fromRecord(record);
      }).toList();

      return campaigns;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get all campaign categories
  static Future<Map<String, String>> getCategories() async {
    try {
      // For now, we'll use the industries as categories
      // In a production app, you might want to fetch these from the backend
      return IndustryList.industries;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Update an existing campaign
  static Future<Campaign> updateCampaign(
      String id, Map<String, dynamic> data) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final record =
          await pb.collection(_collectionName).update(id, body: data);
      return Campaign.fromRecord(record);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Update campaign status
  static Future<Campaign> updateCampaignStatus(String id, String status) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final record = await pb
          .collection(_collectionName)
          .update(id, body: {'status': status});
      return Campaign.fromRecord(record);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
