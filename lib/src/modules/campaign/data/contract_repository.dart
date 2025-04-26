import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/contract.dart';
import 'package:flutter/material.dart';

class ContractRepository {
  static const String _collectionName = 'contracts';

  /// Mark contract as completed (by brand)
  static Future<Contract> completeContract(String contractId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final record = await pb.collection(_collectionName).update(
        contractId,
        body: {"status": "completed"},
      );

      return Contract.fromRecord(record);
    } catch (e) {
      debugPrint('Error completing contract: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Create a new contract after a collaboration is accepted
  static Future<Contract> createContract(
    String campaignId,
    String influencerId,
    List<String> postTypes,
    DateTime deliveryDate,
    double payout,
    String terms,
  ) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.record!.id;

      final body = {
        "campaign": campaignId,
        "brand": userId,
        "influencer": influencerId,
        "post_type": postTypes,
        "delivery_date": deliveryDate.toIso8601String(),
        "payout": payout,
        "terms": terms,
        "is_signed_by_brand": true, // Brand creates and signs initially
        "is_signed_by_influencer": false,
        "status": "pending", // Pending until influencer signs
      };

      final record = await pb.collection(_collectionName).create(body: body);
      return Contract.fromRecord(record);
    } catch (e) {
      debugPrint('Error creating contract: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get contracts for brand
  static Future<List<Contract>> getBrandContracts() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'brand = "$userId"',
            expand: 'campaign,influencer', // Expand related records
          );

      return resultList.items
          .map((record) => Contract.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching brand contracts: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get a contract by ID
  static Future<Contract> getContractById(String contractId) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final record = await pb.collection(_collectionName).getOne(contractId);
      return Contract.fromRecord(record);
    } catch (e) {
      debugPrint('Error fetching contract: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get contract for a specific campaign
  static Future<Contract?> getContractForCampaign(String campaignId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 1,
            filter: 'campaign = "$campaignId"',
          );

      if (resultList.items.isEmpty) {
        debugPrint('No contract found for campaign: $campaignId');
        return null;
      }

      final contract = Contract.fromRecord(resultList.items.first);
      debugPrint(
          'Found contract: ${contract.id} with status: ${contract.status}');
      return contract;
    } catch (e) {
      debugPrint('Error fetching campaign contract: $e');
      // Return null instead of throwing to prevent cascading errors
      return null;
    }
  }

  /// Get contracts for influencer
  static Future<List<Contract>> getInfluencerContracts() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'influencer = "$userId"',
            expand: 'campaign,brand', // Expand related records
          );

      return resultList.items
          .map((record) => Contract.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching influencer contracts: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Reject contract (by influencer)
  static Future<Contract> rejectContract(String contractId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final record = await pb.collection(_collectionName).update(
        contractId,
        body: {"status": "rejected"},
      );

      return Contract.fromRecord(record);
    } catch (e) {
      debugPrint('Error rejecting contract: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Sign contract (by influencer)
  static Future<Contract> signContractByInfluencer(String contractId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final record = await pb.collection(_collectionName).update(
        contractId,
        body: {
          "is_signed_by_influencer": true,
          "status":
              "signed", // Update status to signed when both parties have signed
        },
      );

      return Contract.fromRecord(record);
    } catch (e) {
      debugPrint('Error signing contract by influencer: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
