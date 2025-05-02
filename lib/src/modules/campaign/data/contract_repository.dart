import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
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
      final existingContract = await getContractById(id);

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
      final record = await pb.collection(_collectionName).update(
        id,
        body: {
          'status': 'rejected',
        },
      );
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
      final record = await pb.collection(_collectionName).update(
        id,
        body: {
          'is_signed_by_influencer': true,
          'status': 'signed',
        },
      );

      final signedContract = Contract.fromRecord(record);

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
