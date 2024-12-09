import 'package:connectobia/db/db.dart';

class EditProfileRepo {
  static Future<void> updateInfluencerProfile({
    required String title,
    required String description,
  }) async {
    final pb = await PocketBaseSingleton.instance;
    final id = pb.authStore.record!.id;
    final body = <String, dynamic>{
      "title": title,
      "description": description,
    };

    final record = await pb.collection('influencer').getFirstListItem(
          'user = "$id"',
        );

    final influencerID = record.id;

    await pb.collection('influencer').update(influencerID, body: body);
  }
}
