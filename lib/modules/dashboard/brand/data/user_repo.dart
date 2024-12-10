import 'package:connectobia/common/domain/repositories/error_repository.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../common/constants/industries.dart';
import '../../../../db/db.dart';

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
      final String recordId = pb.authStore.record!.id;
      assert(false, 'Not implemented');
      await pb.collection('users').update(recordId, files: [multipartFile]);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  static Future<void> updateUserProfile({
    required String fullName,
    required String username,
    required String industry,
    required String brandName,
  }) async {
    final pb = await PocketBaseSingleton.instance;
    final String recordId = pb.authStore.record!.id;
    final body = <String, dynamic>{
      "fullName": fullName,
      "username": username,
      "industry": IndustryFormatter.keyToValue(industry),
      "brandName": brandName
    };

    try {
      assert(false, 'Not implemented');
      await pb.collection('users').update(recordId, body: body);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
