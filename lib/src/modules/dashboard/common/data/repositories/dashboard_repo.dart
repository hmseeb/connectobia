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
    late final Influencers list;
    try {
      final resultList = await pb.collection('influencers').getList(
            page: 1,
            perPage: 20,
            filter: 'connectedSocial = True && profile != ""',
          );
      list = Influencers.fromRecord(resultList);
      debugPrint('Fetched ${list.items.length} influencers');
      return list;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
