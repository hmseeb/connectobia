import 'package:connectobia/common/models/influencers.dart';
import 'package:connectobia/db/db.dart';
import 'package:flutter/foundation.dart';

class DashboardRepo {
  static Future<Influencers> getInfluencersList() async {
    final pb = await PocketBaseSingleton.instance;
    late final Influencers list;
    try {
      final resultList = await pb.collection('influencer').getList(
            page: 1,
            perPage: 20,
            // where account type = profile and avatar and banner is not empty
            filter: 'profile != "" && banner != "" && avatar != ""',
            // expand: 'influencer',
          );
      list = Influencers.fromRecord(resultList);
      debugPrint('Fetched ${list.items.length} influencers');
      return list;
    } catch (e) {
      throw Exception(e);
    }
  }
}
