import 'dart:io';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/constants/industries.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


/// [EditProfileRepository] is a class that handles all the edit profile-related operations.
/// It is responsible for updating the influencer profile, updating the user image, and updating the user profile.
class EditProfileRepository {
  /// Update influencer profile (e.g., title, description)
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

    // Get influencer record
    final record = await pb.collection('influencers').getFirstListItem(
          'user = "$id"',
        );

    final influencerID = record.id;

    // Update influencer profile
    await pb.collection('influencers').update(influencerID, body: body);
  }

  /// Update user image (avatar/banner)
  static Future<void> updateUserImage({
    required XFile image,
    required String username,
    required bool isAvatar,  // Use this flag to differentiate avatar/banner
  }) async {
    try {
      // Create multipart file to send in request
      var multipartFile = await http.MultipartFile.fromPath(
        isAvatar ? 'avatar' : 'banner',  // Check if it's avatar or banner
        image.path,
        filename: username,  // Use username as filename (optional)
      );

      final pb = await PocketBaseSingleton.instance;
      final String recordId = pb.authStore.record!.id;

      // Update the user's image (avatar or banner)
      await pb.collection('users').update(recordId, files: [multipartFile]);

      print('Image uploaded successfully');
    } catch (e) {
      // Handle errors in uploading
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Update user profile (fullName, username, industry, brandName)
  static Future<void> updateUserProfile({
    required String fullName,
    required String username,
    required String industry,
    required String brandName,
    XFile? avatar,  // Optional: If the avatar is provided, upload it
    XFile? banner,  // Optional: If the banner is provided, upload it
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final String recordId = pb.authStore.record!.id;

      // Prepare the body for updating user profile fields
      final body = <String, dynamic>{
        "fullName": fullName,
        "username": username,
        "industry": IndustryFormatter.keyToValue(industry),  // Convert industry to correct value
        "brandName": brandName,
      };

      // Update the user profile fields
      await pb.collection('users').update(recordId, body: body);

      print('Profile updated successfully');

      // If avatar is provided, upload it
      if (avatar != null) {
        await updateUserImage(image: avatar, username: username, isAvatar: true);
      }

      // If banner is provided, upload it
      if (banner != null) {
        await updateUserImage(image: banner, username: username, isAvatar: false);
      }

    } catch (e) {
      // Handle errors during profile update
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
