import 'package:connectobia/common/models/brand_profile.dart';
import 'package:connectobia/common/models/influencer_profile.dart';
import 'package:connectobia/db/db.dart';

class SearchRepo {
  static Future<InfluencerProfile> getInfluencerProfile(
      {required String profileId}) async {
    final pb = await PocketBaseSingleton.instance;

    final record = await pb.collection('influencerProfile').getFirstListItem(
          'id = "$profileId"',
        );

    return InfluencerProfile.fromRecord(record);
  }

  static Future<BrandProfile> getBrandProfile(
      {required String profileId}) async {
    final pb = await PocketBaseSingleton.instance;

    final record = await pb.collection('brandProfile').getFirstListItem(
          'id = "$profileId"',
        );

    return BrandProfile.fromRecord(record);
  }
}
