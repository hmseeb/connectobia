import '../../../../../services/storage/pb.dart';
import '../../../../../shared/domain/models/brand_profile.dart';
import '../../../../../shared/domain/models/influencer_profile.dart';

class ProfileRepository {
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
