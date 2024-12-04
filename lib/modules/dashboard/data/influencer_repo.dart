import 'package:connectobia/db/db.dart';
import 'package:connectobia/modules/dashboard/domain/influencer.dart';

class InfluencerRepo {
  static Future<Influencer> getInfluencerProfile(String id) async {
    final pb = await PocketBaseSingleton.instance;

    final record = await pb.collection('influencers').getFirstListItem(
          'user = "$id"',
          expand: 'user',
        );

    return Influencer.fromRecord(record);
  }
}
