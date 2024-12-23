import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:pocketbase/pocketbase.dart';

class RealtimeMessagingRepo {
  Future<RecordModel> getUserById(String userId) async {
    final pb = await PocketBaseSingleton.instance;

    String accountType = CollectionNameSingleton.instance;
    String otherUserAccountType =
        accountType == 'brands' ? 'influencers' : 'brands';

    final record = await pb.collection(otherUserAccountType).getOne(userId);

    return record;
  }
}
