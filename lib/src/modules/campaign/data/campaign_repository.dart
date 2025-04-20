import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/constants/industries.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/data/repositories/funds_repository.dart';
import 'package:connectobia/src/shared/data/repositories/notification_repository.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
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
      final userId = pb.authStore.model.id;

      debugPrint(
          'Assigning influencer: $influencerId to campaign: $campaignId');
      debugPrint('Brand ID (from auth store model): $userId');

      // Update the campaign
      final record = await pb.collection(_collectionName).update(
        campaignId,
        body: {'selected_influencer': influencerId, 'status': 'assigned'},
      );

      final updatedCampaign = Campaign.fromRecord(record);
      debugPrint(
          'Campaign updated with influencer: ${updatedCampaign.selectedInfluencer}');
      debugPrint('Campaign status updated to: ${updatedCampaign.status}');

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

  /// Cancel a campaign (by brand) and release funds
  static Future<Campaign> cancelCampaign(String id) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      // Get the campaign details first to retrieve the budget and brand
      final campaign = await getCampaignById(id);
      final brandId = campaign.brand;
      final budget = campaign.budget;

      // Update campaign status to cancelled
      final record = await pb.collection(_collectionName).update(
        id,
        body: {'status': 'cancelled'},
      );

      // Release locked funds back to the brand
      if (budget > 0) {
        try {
          debugPrint(
              'Releasing $budget funds for brand $brandId after campaign cancellation');
          await FundsRepository.releaseFunds(brandId, budget);
        } catch (e) {
          debugPrint('Error releasing funds after campaign cancellation: $e');
          // Even if releasing funds fails, we don't want to fail the cancellation
        }
      }

      // If there's an associated contract, update its status too
      try {
        final contract = await ContractRepository.getContractByCampaignId(id);
        if (contract != null) {
          await ContractRepository.updateStatus(contract.id, 'cancelled');

          // Notify the influencer if one was assigned
          if (campaign.selectedInfluencer != null &&
              campaign.selectedInfluencer!.isNotEmpty) {
            await NotificationRepository.createNotification(
              userId: campaign.selectedInfluencer!,
              title: 'Campaign Cancelled',
              body:
                  'A campaign you were assigned to has been cancelled by the brand.',
              type: 'campaign_cancelled',
              redirectUrl: '',
            );
          }
        }
      } catch (e) {
        debugPrint('Error updating associated contract: $e');
        // Don't fail the campaign cancellation if contract update fails
      }

      return Campaign.fromRecord(record);
    } catch (e) {
      debugPrint('Error cancelling campaign: $e');
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
      final userId = pb.authStore.model.id;

      // Debug log
      debugPrint('Creating campaign with brand ID: $userId');
      debugPrint(
          'Selected influencer before creation: ${campaign.selectedInfluencer}');

      // Force status to 'draft' regardless of what was passed in the campaign object
      final campaignWithDraftStatus = campaign.copyWith(status: 'draft');
      debugPrint('Forcing status to draft for new campaign');

      // Verify and lock funds first
      if (campaign.budget > 0) {
        try {
          // Import FundsRepository if not already imported at the top
          final fundsLocked =
              await FundsRepository.lockFunds(userId, campaign.budget);
          if (!fundsLocked) {
            throw Exception(
                'Insufficient funds to create this campaign. Please add more funds to your account.');
          }
          debugPrint(
              'Successfully locked ${campaign.budget} funds for campaign');
        } catch (e) {
          debugPrint('Error locking funds: $e');
          throw Exception('Unable to lock funds: ${e.toString()}');
        }
      }

      // Make sure the brand is set to the current user
      final body =
          campaignWithDraftStatus.copyWith(brand: userId).toCreateJson();

      // Debug log body
      debugPrint('Campaign creation body: $body');

      // Create the campaign first
      final record = await pb.collection(_collectionName).create(body: body);
      final createdCampaign = Campaign.fromRecord(record);

      // Debug log
      debugPrint('Campaign created with ID: ${createdCampaign.id}');
      debugPrint(
          'Selected influencer after creation: ${createdCampaign.selectedInfluencer}');
      debugPrint('Campaign status: ${createdCampaign.status}');

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

      // Get the campaign details first to retrieve the budget and brand
      final campaign = await getCampaignById(id);
      final brandId = campaign.brand;
      final budget = campaign.budget;

      // Delete the campaign
      await pb.collection(_collectionName).delete(id);

      // Release locked funds back to the brand
      if (budget > 0) {
        try {
          debugPrint(
              'Releasing $budget funds for brand $brandId after campaign deletion');
          await FundsRepository.releaseFunds(brandId, budget);
        } catch (e) {
          debugPrint('Error releasing funds after campaign deletion: $e');
          // Even if releasing funds fails, we don't want to fail the deletion
        }
      }
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

      // Debug: Log the user ID we're searching with
      debugPrint(
          'Looking for campaigns assigned to influencer with ID: $userId');
      debugPrint('Auth store record: ${pb.authStore.record}');
      debugPrint('Auth store model: ${pb.authStore.model}');

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

        // Check if this campaign should match our filter
        if (item.data['selected_influencer'] == userId) {
          debugPrint(
              'FOUND MATCH: Campaign ${item.id} has current user as selected influencer');
        }
      }

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'selected_influencer = "$userId"',
            sort:
                '-created', // Sort by creation time, descending (newest first)
          );

      debugPrint(
          'Found ${resultList.items.length} campaigns assigned to this influencer');
      debugPrint('Filter used: selected_influencer = "$userId"');

      List<Campaign> campaigns = resultList.items.map((record) {
        return Campaign.fromRecord(record);
      }).toList();

      return campaigns;
    } catch (e) {
      debugPrint('Error fetching assigned campaigns: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get all campaigns available for an influencer
  static Future<List<Campaign>> getAvailableCampaigns() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;

      debugPrint('Getting available campaigns for influencer ID: $userId');

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

      // Now the actual query with improved filter - make sure we exclude campaigns where this influencer is already selected
      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter:
                'status = "active" && (selected_influencer = "" || selected_influencer = null || selected_influencer != "$userId")',
            sort:
                '-created', // Sort by creation time, descending (newest first)
          );

      debugPrint(
          'DEBUG: Available campaigns found: ${resultList.items.length}');
      debugPrint(
          'Filter used: status = "active" && (selected_influencer = "" || selected_influencer = null || selected_influencer != "$userId")');

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

  /// Get all campaigns for the logged-in user (brand or influencer)
  static Future<List<Campaign>> getCampaigns() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;

      // Use the singleton to get collection name
      final collectionName = CollectionNameSingleton.instance;
      final bool isInfluencer = collectionName == "influencers";

      debugPrint(
          'Getting campaigns for user ID: $userId with collection: $collectionName');
      debugPrint(
          'Is user influencer? $isInfluencer (using CollectionNameSingleton)');

      // Check if the user is an influencer or brand
      if (isInfluencer) {
        // For influencers, show campaigns where they are selected
        debugPrint('User is an influencer, fetching assigned campaigns');

        // Get campaigns where this influencer is explicitly selected
        final assignedList = await pb.collection(_collectionName).getList(
              page: 1,
              perPage: 50,
              filter: 'selected_influencer = "$userId"',
              sort:
                  '-created', // Sort by creation time, descending (newest first)
            );

        debugPrint(
            'Found ${assignedList.items.length} campaigns assigned to this influencer');
        for (var item in assignedList.items) {
          debugPrint(
              'Assigned campaign: ${item.id}, Title: ${item.data['title']}, Status: ${item.data['status']}');
        }

        List<Campaign> allCampaigns = assignedList.items.map((record) {
          return Campaign.fromRecord(record);
        }).toList();

        return allCampaigns;
      } else {
        // For brands, show only their campaigns
        debugPrint('User is a brand, fetching brand campaigns');

        final resultList = await pb.collection(_collectionName).getList(
              page: 1,
              perPage: 50,
              filter: 'brand = "$userId"',
              sort:
                  '-created', // Sort by creation time, descending (newest first)
            );

        debugPrint(
            'Found ${resultList.items.length} campaigns created by this brand');

        List<Campaign> campaigns = resultList.items.map((record) {
          return Campaign.fromRecord(record);
        }).toList();

        return campaigns;
      }
    } catch (e) {
      debugPrint('Error in getCampaigns: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get all campaign categories
  static Future<Map<String, String>> getCategories() async {
    try {
      // Use a map with display value as key to avoid duplicates
      Map<String, String> normalizedCategories = {};

      // Add each industry only once with a consistent format
      IndustryList.industries.forEach((key, value) {
        // Only use the display value (value) as the key to avoid duplicates
        normalizedCategories[key] = value;
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
      final userId = pb.authStore.model.id;

      // Get the original campaign to compare budget changes
      final originalCampaign = await getCampaignById(id);
      final originalBudget = originalCampaign.budget;

      // Check if budget is being updated
      if (data.containsKey('budget')) {
        final newBudget = data['budget'] is int
            ? (data['budget'] as int).toDouble()
            : data['budget'] as double;

        // Don't allow budget reductions
        if (newBudget < originalBudget) {
          throw Exception(
              'Budget cannot be reduced. Current budget: $originalBudget');
        }

        // If budget increased, only lock the additional amount
        if (newBudget > originalBudget) {
          final additionalBudget = newBudget - originalBudget;
          debugPrint(
              'Locking additional funds: $additionalBudget (new: $newBudget, original: $originalBudget)');

          if (additionalBudget > 0) {
            try {
              final fundsLocked =
                  await FundsRepository.lockFunds(userId, additionalBudget);
              if (!fundsLocked) {
                throw Exception(
                    'Insufficient funds to increase budget. Please add more funds to your account.');
              }
              debugPrint(
                  'Successfully locked additional $additionalBudget funds for campaign');
            } catch (e) {
              debugPrint('Error locking additional funds: $e');
              throw Exception(
                  'Unable to lock additional funds: ${e.toString()}');
            }
          }
        }
      }

      // Proceed with the update
      final record =
          await pb.collection(_collectionName).update(id, body: data);
      return Campaign.fromRecord(record);
    } catch (e) {
      debugPrint('Error updating campaign: $e');
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
