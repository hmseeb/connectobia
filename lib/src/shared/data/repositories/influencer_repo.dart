import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:flutter/material.dart';

class InfluencerRepository {
  static Future<Influencer> getInfluencerById(String id) async {
    final pb = await PocketBaseSingleton.instance;
    try {
      debugPrint('User is Influencer');
      debugPrint('Attempting to load influencer user with ID: $id');

      // Try to approach directly with the second, working approach
      // Look up the influencer by searching for an influencer with the profile ID matching our ID
      debugPrint('Searching for influencer with profile=$id');
      final influencersResult = await pb.collection('influencers').getList(
            filter: 'profile = "$id"',
            page: 1,
            perPage: 1,
          );

      if (influencersResult.items.isNotEmpty) {
        final record = influencersResult.items.first;
        debugPrint('✅ Found matching influencer: ${record.data['fullName']}');
        return Influencer.fromRecord(record);
      }

      // If that fails, try the original approach as fallback
      debugPrint('No influencer found by profile ID, trying direct ID lookup');
      final record = await pb.collection('influencers').getOne(id);
      debugPrint('✅ Successfully loaded influencer with ID: $id');
      return Influencer.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Error getting influencer by ID $id: $e');
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
