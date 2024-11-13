import 'package:connectobia/db/db.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UserRepo {
  static Future<void> updateUserImage({
    required XFile image,
    required String username,
    required bool isAvatar,
  }) async {
    try {
      var multipartFile = await http.MultipartFile.fromPath(
        isAvatar ? 'avatar' : 'banner',
        image.path,
        filename: username, // You can change this to any file name
      );
      final pb = await PocketBaseSingleton.instance;
      final String recordId = pb.authStore.model.id;
      await pb.collection('users').update(recordId, files: [multipartFile]);
    } catch (e) {
      rethrow;
    }
  }

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
