import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/collaboration.dart';
import 'package:flutter/material.dart';

class CollaborationRepository {
  static const String _collectionName = 'collaborations';

  /// Accept a collaboration request (by influencer)
  static Future<Collaboration> acceptCollaboration(
      String collaborationId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final record = await pb.collection(_collectionName).update(
        collaborationId,
        body: {"status": "accepted"},
      );

      return Collaboration.fromRecord(record);
    } catch (e) {
      debugPrint('Error accepting collaboration: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Counter offer to a collaboration (by influencer)
  static Future<Collaboration> counterOfferCollaboration(
      String collaborationId, double counterAmount, String message) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;

      final record = await pb.collection(_collectionName).update(
        collaborationId,
        body: {
          "proposed_amount": counterAmount,
          "message": message,
          "status": "countered",
          "send_by": userId,
        },
      );

      return Collaboration.fromRecord(record);
    } catch (e) {
      debugPrint('Error making counter offer: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Create a new collaboration request
  static Future<Collaboration> createCollaboration(String campaignId,
      String influencerId, double proposedAmount, String message) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.record!.id;

      final body = {
        "campaign": campaignId,
        "brand": userId,
        "influencer": influencerId,
        "proposed_amount": proposedAmount,
        "status": "pending",
        "message": message,
        "send_by": userId,
      };

      final record = await pb.collection(_collectionName).create(body: body);
      return Collaboration.fromRecord(record);
    } catch (e) {
      debugPrint('Error creating collaboration: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get collaborations created by a brand
  static Future<List<Collaboration>> getBrandCollaborations() async {
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
          .map((record) => Collaboration.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching brand collaborations: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get all collaborations for a specific campaign
  static Future<List<Collaboration>> getCampaignCollaborations(
      String campaignId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 50,
            filter: 'campaign = "$campaignId"',
          );

      return resultList.items
          .map((record) => Collaboration.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching campaign collaborations: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get collaborations sent to an influencer
  static Future<List<Collaboration>> getInfluencerCollaborations() async {
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
          .map((record) => Collaboration.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('Error fetching influencer collaborations: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Reject a collaboration request (by influencer)
  static Future<Collaboration> rejectCollaboration(
      String collaborationId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final record = await pb.collection(_collectionName).update(
        collaborationId,
        body: {"status": "rejected"},
      );

      return Collaboration.fromRecord(record);
    } catch (e) {
      debugPrint('Error rejecting collaboration: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
