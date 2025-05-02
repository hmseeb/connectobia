import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:flutter/material.dart';

class BrandRepository {
  static Future<Brand> getBrandById(String id) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final record = await pb.collection('brands').getOne(id);
      return Brand.fromRecord(record);
    } catch (e) {
      debugPrint('Error getting brand by ID: $e');
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

      await pb.collection('brandProfile').update(
        profileId,
        body: {'description': description},
      );
    } catch (e) {
      debugPrint('Error updating brand profile: $e');
      final errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
