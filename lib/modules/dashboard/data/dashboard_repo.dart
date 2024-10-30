import 'package:connectobia/db/db.dart';
import 'package:connectobia/modules/dashboard/application/domain/user_list.dart';
import 'package:flutter/foundation.dart';

class DashboardRepo {
  static Future<UserList> getUserList() async {
    final pb = await PocketBaseSingleton.instance;
    late final UserList userLists;
    try {
      final resultList = await pb.collection('users').getList(
            page: 1,
            perPage: 20,
            // where account type = inflencer
            filter: 'account_type = "influencer"',
          );
      userLists = UserList.fromRecord(resultList);
      debugPrint('Fetched ${userLists.items.length} influencers');
      return userLists;
    } catch (e) {
      rethrow;
    }
  }
}
