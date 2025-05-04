import 'package:flutter/material.dart';

import '../../../../../services/storage/pb.dart';
import '../../../../../shared/data/repositories/error_repo.dart';
import '../../../../../shared/domain/models/brand_profile.dart';
import '../../../../../shared/domain/models/influencer_profile.dart';

class ProfileRepository {
  static Future<BrandProfile> getBrandProfile(
      {required String profileId}) async {
    final pb = await PocketBaseSingleton.instance;

    debugPrint(
        '🔍 ProfileRepository: Attempting to get brand profile with ID: $profileId');

    try {
      // First try to get the record directly by ID
      final record = await pb.collection('brandProfile').getOne(profileId);
      debugPrint('✅ Found brand profile directly with ID: $profileId');
      return BrandProfile.fromRecord(record);
    } catch (e) {
      debugPrint('⚠️ Failed to get profile directly: $e');

      // If direct fetch fails, try using a filter
      try {
        debugPrint('Trying alternative filter approach...');
        final record = await pb.collection('brandProfile').getFirstListItem(
              'id = "$profileId"',
            );
        debugPrint('✅ Found brand profile by filter with ID: $profileId');
        return BrandProfile.fromRecord(record);
      } catch (e) {
        debugPrint('❌ Failed to find brand profile with ID $profileId: $e');
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    }
  }

  static Future<InfluencerProfile> getInfluencerProfile(
      {required String profileId}) async {
    final pb = await PocketBaseSingleton.instance;

    debugPrint(
        '🔍 ProfileRepository: Attempting to get influencer profile with ID: $profileId');

    try {
      // First try to get the record directly by ID
      final record = await pb.collection('influencerProfile').getOne(profileId);
      debugPrint('✅ Found influencer profile directly with ID: $profileId');
      return InfluencerProfile.fromRecord(record);
    } catch (e) {
      debugPrint('⚠️ Failed to get profile directly: $e');

      // If direct fetch fails, try using a filter
      try {
        debugPrint('Trying alternative filter approach...');
        final record =
            await pb.collection('influencerProfile').getFirstListItem(
                  'id = "$profileId"',
                );
        debugPrint('✅ Found influencer profile by filter with ID: $profileId');
        return InfluencerProfile.fromRecord(record);
      } catch (e) {
        debugPrint(
            '❌ Failed to find influencer profile with ID $profileId: $e');
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    }
  }
}
