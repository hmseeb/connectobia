import 'dart:convert';

import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/data/repositories/funds_repository.dart';
import 'package:connectobia/src/shared/data/repositories/notification_repository.dart';
import 'package:connectobia/src/shared/domain/models/contract.dart';
import 'package:flutter/material.dart';

class ContractRepository {
  static const String _collectionName = 'contracts';

  /// Create a new contract associated with a campaign
  static Future<Contract> createContract(Contract contract) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      debugPrint(
          'ContractRepository: Creating contract for campaign ${contract.campaign}');

      // Create the contract with brand signature already set to true
      final body = contract
          .copyWith(
            isSignedByBrand: true,
            isSignedByInfluencer: false,
            status: 'pending',
          )
          .toJson();

      debugPrint('ContractRepository: Contract request body: $body');

      try {
        final record = await pb.collection(_collectionName).create(body: body);
        debugPrint(
            'ContractRepository: Contract created with ID: ${record.id}');
        return Contract.fromRecord(record);
      } catch (e) {
        debugPrint(
            'ContractRepository: PocketBase error creating contract: $e');
        if (e.toString().contains('Failed to convert')) {
          debugPrint(
              'ContractRepository: This may be a data type mismatch. Check the field types.');
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('ContractRepository: Error creating contract: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Test function to create a contract with explicit values
  static Future<Contract?> createTestContract(
    String campaignId,
    String brandId,
    String influencerId, {
    String? guidelines,
  }) async {
    try {
      debugPrint('Creating TEST contract for debugging purposes');
      debugPrint('Campaign ID: $campaignId');
      debugPrint('Brand ID: $brandId');
      debugPrint('Influencer ID: $influencerId');

      // Create a test contract with predefined values
      final testContract = Contract(
        id: '', // Will be set by the database
        campaign: campaignId,
        brand: brandId,
        influencer: influencerId,
        postType: ['post', 'story'],
        deliveryDate: DateTime.now().add(const Duration(days: 14)),
        payout: 500.0,
        terms: 'Test terms for debugging purposes',
        guidelines: guidelines ?? 'Test content guidelines for debugging',
        isSignedByBrand: true,
        isSignedByInfluencer: false,
        status: 'pending',
      );

      // Log the test contract JSON for debugging
      debugPrint('TEST Contract JSON: ${testContract.toJson()}');

      // Create the contract
      try {
        final createdContract = await createContract(testContract);
        debugPrint(
            'TEST Contract created successfully! ID: ${createdContract.id}');
        return createdContract;
      } catch (e) {
        debugPrint('Error creating TEST contract: $e');
        return null;
      }
    } catch (e) {
      debugPrint('Unexpected error in createTestContract: $e');
      return null;
    }
  }

  /// Get all contracts for a brand
  static Future<List<Contract>> getBrandContracts() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            expand: 'campaign,influencer,brand',
            filter: 'brand = "$userId"',
          );

      return resultList.items.map((record) {
        return Contract.fromRecord(record);
      }).toList();
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get contract by campaign ID
  static Future<Contract?> getContractByCampaignId(String campaignId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 1,
            filter: 'campaign = "$campaignId"',
          );

      if (resultList.items.isEmpty) {
        return null;
      }

      return Contract.fromRecord(resultList.items.first);
    } catch (e) {
      debugPrint('Error getting contract by campaign ID: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get contract by ID
  static Future<Contract> getContractById(String id) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final record = await pb.collection(_collectionName).getOne(id);
      return Contract.fromRecord(record);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get all contracts for an influencer
  static Future<List<Contract>> getInfluencerContracts() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            expand: 'campaign,influencer,brand',
            filter: 'influencer = "$userId"',
          );

      return resultList.items.map((record) {
        return Contract.fromRecord(record);
      }).toList();
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Mark contract as completed, allowing both parties to leave reviews
  static Future<Contract> markAsCompleted(String id) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      // First, get the contract to ensure it exists and to get related data

      // Update the contract status to completed
      final record = await pb.collection(_collectionName).update(
        id,
        body: {'status': 'completed'},
      );

      final completedContract = Contract.fromRecord(record);

      // Send notifications to both parties that they can now leave reviews
      try {
        // Notify the brand
        await NotificationRepository.createNotification(
          userId: completedContract.brand,
          title: 'Contract Completed',
          body:
              'The contract has been marked as completed. You can now leave a review for the influencer.',
          type: 'contract_completed',
          redirectUrl: '$reviewScreen?contractId=${completedContract.id}',
        );

        // Notify the influencer
        await NotificationRepository.createNotification(
          userId: completedContract.influencer,
          title: 'Contract Completed',
          body:
              'The contract has been marked as completed. You can now leave a review for the brand.',
          type: 'contract_completed',
          redirectUrl: '$reviewScreen?contractId=${completedContract.id}',
        );
      } catch (e) {
        debugPrint('Error sending contract completion notifications: $e');
        // Don't fail the contract completion if notifications fail
      }

      return completedContract;
    } catch (e) {
      debugPrint('Error marking contract as completed: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Reject contract by influencer
  static Future<Contract> rejectByInfluencer(String id) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      // Get the existing contract to retrieve the campaign and amount
      final existingContract = await getContractById(id);
      final campaignId = existingContract.campaign;
      final brandId = existingContract.brand;
      final amount = existingContract.payout;

      // Update the contract status to rejected
      final record = await pb.collection(_collectionName).update(
        id,
        body: {
          'status': 'rejected',
        },
      );

      // Also update the campaign status to rejected
      try {
        await pb.collection('campaigns').update(
          campaignId,
          body: {
            'status': 'rejected',
          },
        );
        debugPrint('Updated campaign $campaignId status to rejected');
      } catch (e) {
        debugPrint('Error updating campaign status: $e');
        // Don't fail the contract rejection if campaign update fails
      }

      // Release locked funds back to the brand
      if (amount > 0) {
        try {
          debugPrint(
              'Releasing $amount funds for brand $brandId after contract rejection');
          await FundsRepository.releaseFunds(brandId, amount);
        } catch (e) {
          debugPrint('Error releasing funds after contract rejection: $e');
          // Even if releasing funds fails, we don't want to fail the rejection
        }
      }

      // Create notification for the brand about rejection
      try {
        await NotificationRepository.createNotification(
          userId: brandId,
          title: 'Contract Rejected',
          body:
              'An influencer has rejected your campaign contract. Your funds have been released.',
          type: 'contract_rejected',
          redirectUrl: '$campaignDetails?campaignId=$campaignId&userType=brand',
        );
      } catch (e) {
        debugPrint('Error creating notification after contract rejection: $e');
        // Do not fail the contract rejection if notification fails
      }

      return Contract.fromRecord(record);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Sign contract by influencer
  static Future<Contract> signByInfluencer(String id) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      // Get the contract details first to retrieve the campaign ID
      final existingContract = await getContractById(id);
      final campaignId = existingContract.campaign;

      // Update the contract to signed status
      final record = await pb.collection(_collectionName).update(
        id,
        body: {
          'is_signed_by_influencer': true,
          'status': 'signed',
        },
      );

      final signedContract = Contract.fromRecord(record);

      // Also update the campaign status to active
      try {
        await pb.collection('campaigns').update(
          campaignId,
          body: {
            'status': 'active',
          },
        );
        debugPrint('Updated campaign $campaignId status to active');
      } catch (e) {
        debugPrint('Error updating campaign status: $e');
        // Don't fail the contract signing if campaign update fails
      }

      // Create notification for the brand
      try {
        // Create notification for brand owner
        await NotificationRepository.createContractSignedNotification(
          brandId: signedContract.brand,
          influencerName:
              "Influencer", // Generic name since we don't have detailed info
          contractId: signedContract.id,
          campaignTitle: "your campaign", // Generic title
        );
      } catch (e) {
        debugPrint('Error creating notification after contract signing: $e');
        // Do not fail the contract signing if notification fails
      }

      return signedContract;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Update post URLs for a contract
  static Future<Contract> updatePostUrls(String id, String postUrlJson) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      debugPrint('Updating post URLs for contract $id: $postUrlJson');

      // Check for empty input
      if (postUrlJson.trim().isEmpty) {
        debugPrint('Empty postUrlJson provided, setting to empty array');
        postUrlJson = "[]";
      }

      // Add more debug info
      debugPrint(
          'POST URL FORMAT CHECK: Type: ${postUrlJson.runtimeType}, Length: ${postUrlJson.length}');

      // Parse the JSON to ensure it's an array
      List<String> urlList = [];
      try {
        // Parse to get a proper list
        final parsedJson = jsonDecode(postUrlJson);
        if (parsedJson is List) {
          // Convert all items to strings
          urlList = parsedJson.map((item) => item.toString()).toList();
        } else {
          // If not a list, make it a single-item list
          urlList = [parsedJson.toString()];
        }
      } catch (e) {
        debugPrint('JSON PARSING ERROR: $e');
        // If we can't parse it, try to use it as a single URL
        urlList = [postUrlJson];
      }

      debugPrint('Parsed URL list: $urlList');

      // Send the list directly - NOT as a JSON string
      // This is critical: PocketBase will handle serializing the list to JSON
      final record = await pb.collection(_collectionName).update(
        id,
        body: {'postUrls': urlList},
      );

      // Log response for verification
      debugPrint('UPDATE RESPONSE: ${record.data}');
      if (record.data['postUrls'] != null) {
        debugPrint('SAVED POST_URLs: ${record.data['postUrls']}');
        debugPrint(
            'SAVED POST_URLs type: ${record.data['postUrls'].runtimeType}');
      }

      // Create notification for the brand that content has been submitted
      final updatedContract = Contract.fromRecord(record);

      try {
        // Create notification for brand
        await NotificationRepository.createNotification(
          userId: updatedContract.brand,
          title: 'Content Submitted',
          body: 'The influencer has submitted content for review.',
          type: 'content',
          redirectUrl:
              '$campaignDetails?campaignId=${updatedContract.campaign}&userType=brand',
        );
      } catch (e) {
        debugPrint('Error creating notification after content submission: $e');
        // Do not fail the URL update if notification fails
      }

      return updatedContract;
    } catch (e) {
      debugPrint('Error updating post URLs: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Update contract status
  static Future<Contract> updateStatus(String id, String status) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      // If status is 'completed', use the specialized method
      if (status == 'completed') {
        return await markAsCompleted(id);
      }

      // Otherwise, just update the status
      final record = await pb.collection(_collectionName).update(
        id,
        body: {'status': status},
      );
      return Contract.fromRecord(record);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
