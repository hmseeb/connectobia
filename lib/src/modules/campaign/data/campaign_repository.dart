import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/constants/industries.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/data/repositories/notification_repository.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:connectobia/src/shared/domain/models/contract.dart';
import 'package:flutter/material.dart';

import 'contract_repository.dart';

class CampaignRepository {
  static const String _collectionName = 'campaigns';

  /// Assign influencer to campaign and create a contract
  static Future<Campaign> assignInfluencer(
    String campaignId,
    String influencerId, {
    List<String>? postTypes,
    DateTime? deliveryDate,
    String? terms,
    String? guidelines,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.record!.id;

      debugPrint(
          'Assigning influencer: $influencerId to campaign: $campaignId');

      // Update the campaign
      final record = await pb.collection(_collectionName).update(
        campaignId,
        body: {'selected_influencer': influencerId, 'status': 'assigned'},
      );

      final updatedCampaign = Campaign.fromRecord(record);
      debugPrint(
          'Campaign updated with influencer: ${updatedCampaign.selectedInfluencer}');

      // Create a contract for this assignment
      try {
        // Get the campaign details to use for contract
        final campaign = await getCampaignById(campaignId);
        debugPrint(
            'Retrieved campaign details for contract: ${campaign.id}, budget: ${campaign.budget}');

        // Default values if not provided
        final contractPostTypes = postTypes ?? ['post'];
        final contractDeliveryDate =
            deliveryDate ?? campaign.endDate.subtract(const Duration(days: 3));
        final contractTerms = terms ?? 'Standard terms for content creation';
        final contractGuidelines = guidelines;

        debugPrint(
            'Contract details - Post types: $contractPostTypes, Delivery date: $contractDeliveryDate');
        debugPrint(
            'Contract terms: $contractTerms, Guidelines: $contractGuidelines');

        // Create a contract
        final contract = Contract(
          id: '', // Will be set by the database
          campaign: campaignId,
          brand: userId,
          influencer: influencerId,
          postType: contractPostTypes,
          deliveryDate: contractDeliveryDate,
          payout: campaign.budget,
          terms: contractTerms,
          guidelines: contractGuidelines ?? '',
          isSignedByBrand: true,
          isSignedByInfluencer: false,
          status: 'pending',
        );

        debugPrint('Contract object created: ${contract.toJson()}');

        final createdContract =
            await ContractRepository.createContract(contract);
        debugPrint(
            'Contract created successfully with ID: ${createdContract.id}');

        // Create a notification for the influencer about the new contract
        await NotificationRepository.createContractNotification(
          userId: influencerId,
          contractId: createdContract.id,
          campaignTitle: campaign.title,
        );
      } catch (e) {
        debugPrint('Error creating contract for assignment: $e');
        // Don't fail the assignment if contract creation fails
      }

      return updatedCampaign;
    } catch (e) {
      debugPrint('Error in assignInfluencer: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Create a new campaign with a contract
  static Future<Campaign> createCampaign(
    Campaign campaign, {
    List<String>? postTypes,
    DateTime? deliveryDate,
    String? terms,
    String? guidelines,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.record!.id;

      // Debug log
      debugPrint('Creating campaign with brand ID: $userId');
      debugPrint(
          'Selected influencer before creation: ${campaign.selectedInfluencer}');

      // Make sure the brand is set to the current user
      final body = campaign.copyWith(brand: userId).toCreateJson();

      // Debug log body
      debugPrint('Campaign creation body: $body');

      // Create the campaign first
      final record = await pb.collection(_collectionName).create(body: body);
      final createdCampaign = Campaign.fromRecord(record);

      // Debug log
      debugPrint('Campaign created with ID: ${createdCampaign.id}');
      debugPrint(
          'Selected influencer after creation: ${createdCampaign.selectedInfluencer}');

      // Default values if not provided
      final contractPostTypes = postTypes ?? ['post'];
      final contractDeliveryDate = deliveryDate ??
          createdCampaign.endDate.subtract(const Duration(days: 3));
      final contractTerms = terms ?? 'Standard terms for content creation';
      final contractGuidelines = guidelines;

      // Debug log contract values
      debugPrint('Contract terms: $contractTerms');
      debugPrint('Contract guidelines: $contractGuidelines');
      debugPrint('Contract post types: $contractPostTypes');
      debugPrint('Contract delivery date: $contractDeliveryDate');

      // If an influencer is assigned, create a contract
      if (createdCampaign.selectedInfluencer != null &&
          createdCampaign.selectedInfluencer!.isNotEmpty) {
        try {
          debugPrint(
              'Creating contract for campaign: ${createdCampaign.id} with influencer: ${createdCampaign.selectedInfluencer}');

          // Create a contract for this campaign
          final contract = Contract(
            id: '', // Will be set by the database
            campaign: createdCampaign.id,
            brand: userId,
            influencer: createdCampaign.selectedInfluencer!,
            postType: contractPostTypes,
            deliveryDate: contractDeliveryDate,
            payout: createdCampaign.budget,
            terms: contractTerms,
            guidelines: contractGuidelines ?? '',
            isSignedByBrand: true,
            isSignedByInfluencer: false,
            status: 'pending',
          );

          // Debug log contract object
          debugPrint('Contract object: ${contract.toJson()}');

          final createdContract =
              await ContractRepository.createContract(contract);
          debugPrint(
              'Contract created successfully with ID: ${createdContract.id}');

          // Create a notification after successfully creating a contract
          await NotificationRepository.createContractNotification(
            userId: createdCampaign.selectedInfluencer!,
            contractId: createdContract.id,
            campaignTitle: createdCampaign.title,
          );
        } catch (e) {
          debugPrint('Error creating contract: $e');
          // Don't fail the campaign creation if contract creation fails
        }
      } else {
        debugPrint(
            'No influencer assigned to campaign. Skipping contract creation.');
      }

      return createdCampaign;
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
      final userId = pb.authStore.record?.id ?? '';

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
      debugPrint('Fetching campaign with ID: $id');
      final pb = await PocketBaseSingleton.instance;

      // Check if the ID is valid
      if (id.isEmpty) {
        throw Exception('Campaign ID is empty');
      }

      final record = await pb.collection(_collectionName).getOne(id);
      debugPrint('Campaign found: ${record.id}');
      return Campaign.fromRecord(record);
    } catch (e) {
      debugPrint('Error fetching campaign by ID: $e');

      // Check for specific error types and provide more context
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        debugPrint('Campaign with ID: $id not found');
      }

      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get all campaigns for the logged-in brand
  static Future<List<Campaign>> getCampaigns() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.record?.id ?? '';

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
      // But we need to ensure consistent formatting between app and database
      Map<String, String> normalizedCategories = {};

      // Convert keys to ensure they match database format
      IndustryList.industries.forEach((key, value) {
        // Add both formats to support database inconsistencies
        normalizedCategories[key] = value; // Original (with underscores)
        normalizedCategories[key.replaceAll('_', ' ')] = value; // With spaces
      });

      return normalizedCategories;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Normalize a category key to ensure it matches database format
  static String normalizeCategoryKey(String category) {
    // Support both formats when comparing or storing
    if (category.contains('_')) {
      return category; // Already has underscores
    } else if (IndustryList.industries.containsKey(category)) {
      return category; // It's a valid industry key
    } else {
      // Try to match by converting spaces to underscores
      String withUnderscores = category.replaceAll(' ', '_');
      if (IndustryList.industries.containsKey(withUnderscores)) {
        return withUnderscores;
      }
      // Otherwise keep original
      return category;
    }
  }

  /// Test function to create a contract for an existing campaign
  static Future<void> testCreateContractForCampaign(String campaignId) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.record!.id;

      // Get the campaign details
      final campaign = await getCampaignById(campaignId);
      debugPrint(
          'Test: Retrieved campaign: ${campaign.id}, brand: ${campaign.brand}');

      // Check if the campaign has an influencer
      if (campaign.selectedInfluencer == null ||
          campaign.selectedInfluencer!.isEmpty) {
        debugPrint(
            'Test: Campaign has no assigned influencer. Cannot create contract.');
        return;
      }

      // Create a test contract using the ContractRepository
      final contract = await ContractRepository.createTestContract(
          campaignId, userId, campaign.selectedInfluencer!);

      debugPrint(
          'Test: Contract created successfully with ID: ${contract!.id}');
    } catch (e) {
      debugPrint('Test: Error creating test contract: $e');
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
