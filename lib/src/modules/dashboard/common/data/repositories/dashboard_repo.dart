import 'package:flutter/foundation.dart';

import '../../../../../services/storage/pb.dart';
import '../../../../../shared/data/repositories/error_repo.dart';
import '../../../../../shared/domain/models/brands.dart';
import '../../../../../shared/domain/models/influencers.dart';

class DashboardRepository {
  static Future<Brands> getBrandsList() async {
    final pb = await PocketBaseSingleton.instance;
    late final Brands list;
    try {
      final resultList = await pb.collection('brands').getList(
            page: 1,
            perPage: 20,
            filter: 'profile != ""',
          );
      list = Brands.fromRecord(resultList);
      debugPrint('Fetched ${list.items.length} brands');
      return list;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  static Future<Influencers> getInfluencersList() async {
    final pb = await PocketBaseSingleton.instance;

    try {
      // Fetch only verified influencers
      final resultList = await pb.collection('influencers').getList(
            page: 1,
            perPage: 50,
            // Filter for verified influencers only
            filter: 'connectedSocial = True && profile != ""',
          );

      final list = Influencers.fromRecord(resultList);
      debugPrint('Fetched ${list.items.length} verified influencers');

      // If no influencers found, create empty list instead of throwing error
      if (list.items.isEmpty) {
        debugPrint('Warning: No verified influencers found in the database');
      }

      return list;
    } catch (e) {
      debugPrint('Error fetching influencers: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
