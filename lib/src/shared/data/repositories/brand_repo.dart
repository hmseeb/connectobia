import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:flutter/material.dart';

class BrandRepository {
  static Future<Brand> getBrandById(String id) async {
    final pb = await PocketBaseSingleton.instance;
    try {
      debugPrint('User is Brand');
      debugPrint('Attempting to load brand user with ID: $id');

      // Try to approach directly with the second, working approach
      // Look up the brand by searching for a brand with the profile ID matching our ID
      debugPrint('Searching for brand with profile=$id');
      final brandsResult = await pb.collection('brands').getList(
            filter: 'profile = "$id"',
            page: 1,
            perPage: 1,
          );

      if (brandsResult.items.isNotEmpty) {
        final record = brandsResult.items.first;
        debugPrint('✅ Found matching brand: ${record.data['brandName']}');
        return Brand.fromRecord(record);
      }

      // If that fails, try the original approach as fallback
      debugPrint('No brand found by profile ID, trying direct ID lookup');
      final record = await pb.collection('brands').getOne(id);
      debugPrint('✅ Successfully loaded brand with ID: $id');
      return Brand.fromRecord(record);
    } catch (e) {
      debugPrint('❌ Error getting brand by ID $id: $e');
      final errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  static Future<void> updateBrand(String id, Map<String, dynamic> data) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      await pb.collection('brands').update(id, body: data);
    } catch (e) {
      debugPrint('Error updating brand: $e');
      final errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  static Future<void> updateBrandProfile({
    required Brand brand,
    required String description,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final profileId = brand.profile;

      if (profileId.isEmpty) {
        throw Exception('Brand has no profile');
      }

      debugPrint('Updating brand profile with ID: $profileId');
      debugPrint('Description: $description');

      // First try to update using the standard approach
      try {
        await pb.collection('brandProfile').update(
          profileId,
          body: {'description': description},
        );
        debugPrint('Successfully updated brand profile');
      } catch (e) {
        debugPrint(
            'Error with standard update, trying alternative approach: $e');

        // If direct update fails, try using a filter approach first to verify the profile exists
        final record = await pb.collection('brandProfile').getFirstListItem(
              'id = "$profileId"',
            );

        // Now update with the confirmed ID
        await pb.collection('brandProfile').update(
          record.id,
          body: {'description': description},
        );
        debugPrint(
            'Successfully updated brand profile using alternative approach');
      }
    } catch (e) {
      debugPrint('Error updating brand profile: $e');
      final errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
