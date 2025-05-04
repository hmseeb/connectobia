import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:flutter/material.dart';

class InfluencerRepository {
  static Future<Influencer> getInfluencerById(String id) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final record = await pb.collection('influencers').getOne(id);
      return Influencer.fromRecord(record);
    } catch (e) {
      debugPrint('Error getting influencer by ID: $e');
      final errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  static Future<void> updateInfluencer(
      String id, Map<String, dynamic> data) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      await pb.collection('influencers').update(id, body: data);
    } catch (e) {
      debugPrint('Error updating influencer: $e');
      final errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  static Future<void> updateInfluencerProfile({
    required Influencer influencer,
    required String description,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final profileId = influencer.profile;

      if (profileId.isEmpty) {
        throw Exception('Influencer has no profile');
      }

      debugPrint('Updating influencer profile with ID: $profileId');
      debugPrint('Description: $description');

      // First try to update using the standard approach
      try {
        await pb.collection('influencerProfile').update(
          profileId,
          body: {'description': description},
        );
        debugPrint('Successfully updated influencer profile');
      } catch (e) {
        debugPrint(
            'Error with standard update, trying alternative approach: $e');

        // If direct update fails, try using a filter approach first to verify the profile exists
        final record =
            await pb.collection('influencerProfile').getFirstListItem(
                  'id = "$profileId"',
                );

        // Now update with the confirmed ID
        await pb.collection('influencerProfile').update(
          record.id,
          body: {'description': description},
        );
        debugPrint(
            'Successfully updated influencer profile using alternative approach');
      }
    } catch (e) {
      debugPrint('Error updating influencer profile: $e');
      final errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
