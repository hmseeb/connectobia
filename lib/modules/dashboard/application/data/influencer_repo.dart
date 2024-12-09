import 'package:connectobia/common/models/influencer_profile.dart';
import 'package:connectobia/db/db.dart';

class InfluencerRepo {
  static Future<InfluencerProfile> getInfluencerProfile(
      String profileId) async {
    final pb = await PocketBaseSingleton.instance;

    final record = await pb.collection('influencerProfile').getFirstListItem(
          'id = "$profileId"',
          expand: 'user',
        );

    return InfluencerProfile.fromRecord(record);
  }
}
