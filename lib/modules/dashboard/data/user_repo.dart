import 'package:connectobia/db/db.dart';

class UserRepo {
  static Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String industry,
    required String brandName,
  }) async {
    final pb = await PocketBaseSingleton.instance;
    final String recordId = pb.authStore.model.id;
    final body = <String, dynamic>{
      "first_name": firstName,
      "last_name": lastName,
      "username": username,
      "industry": industry,
      "brand_name": brandName
    };

    try {
      await pb.collection('users').update(recordId, body: body);
    } catch (e) {
      rethrow;
    }
  }
}
