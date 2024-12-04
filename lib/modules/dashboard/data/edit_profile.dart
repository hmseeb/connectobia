import 'package:connectobia/db/db.dart';

class EditProfileRepo {
  static Future<void> updateInfluencerProfile({
    required String title,
    required String description,
  }) async {
    final pb = await PocketBaseSingleton.instance;
    final id = pb.authStore.model.id;
    final body = <String, dynamic>{
      "title": title,
      "description": description,
    };

    final record = await pb.collection('influencers').getFirstListItem(
          'user = "$id"',
        );

    final influencerID = record.id;

    await pb.collection('influencers').update(influencerID, body: body);
  }
}
