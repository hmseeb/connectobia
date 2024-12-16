import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/constants/industries.dart';
import '../../../../common/domain/repositories/error_repository.dart';
import '../../../../common/models/user.dart';
import '../../../../common/singletons/account_type.dart';
import '../../../../db/db.dart';
import '../../domain/model/brand.dart';
import '../../domain/model/influencer.dart';

/// [AuthRepo] is a repository class that contains all the methods that are
/// responsible for handling authentication related operations.
///
/// {@category Repositories}
class AuthRepo {
  /// [createBrandAccount] is a method that creates a new user account.
  static Future<RecordModel> createBrandAccount({
    required String brandName,
    required String username,
    required String email,
    required String password,
    required String industry,
  }) async {
    final body = <String, dynamic>{
      // "username": email.split('@')[0],
      "email": email,
      "password": password,
      "passwordConfirm": password,
      "brandName": brandName,
      "username": username,
      "emailVisibility": false,
      "industry": IndustryFormatter.keyToValue(industry),
    };

    try {
      final pb = await PocketBaseSingleton.instance;
      RecordModel user = await pb.collection('brand').create(body: body);
      await pb.collection('brand').requestVerification(email);
      debugPrint('Created account for $email');
      return user;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// [createInfluencer] is a method that creates a new user account.
  static Future<RecordModel> createInfluencerAccount({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String industry,
  }) async {
    final body = <String, dynamic>{
      // "username": email.split('@')[0],
      "email": email,
      "password": password,
      "passwordConfirm": password,
      "fullName": fullName,
      "username": username,
      "emailVisibility": false,
      "industry": IndustryFormatter.keyToValue(industry),
    };

    try {
      final pb = await PocketBaseSingleton.instance;
      RecordModel user = await pb.collection('influencer').create(body: body);
      await pb.collection('influencer').requestVerification(email);
      debugPrint('Created account for $email');
      return user;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// [forgotPassword] is a method that sends a password reset email to the
  /// user's email address.
  static Future<void> forgotPassword(
      {required String email, required String collectionName}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      return await pb.collection(collectionName).requestPasswordReset(email);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// [getUser] is a method that returns the current user's information.
  static Future<dynamic> getUser() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      if (!pb.authStore.isValid) {
        return null;
      }
      final id = pb.authStore.record!.id;
      final collectionName = pb.authStore.record!.collectionName;
      CollectionNameSingleton.instance = collectionName;
      RecordModel record = await pb.collection(collectionName).getOne(id);
      if (collectionName == 'brand') {
        final Brand user = Brand.fromRecord(record);
        return user;
      } else {
        final Influencer user = Influencer.fromRecord(record);
        return user;
      }
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  ///  [instagramAuth] is a method that authenticates a user with their Instagram brand account.
  static Future<Influencer> instagramAuth(
      {required String collectionName}) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final recordAuth = await pb
          .collection(collectionName)
          .authWithOAuth2('instagram2', (url) async {
        await launchUrl(url);
      });

      // Implement brand if instagram auth is introduced for brands in future

      final Influencer influencer = Influencer.fromRecord(recordAuth.record);
      final Meta meta = Meta.fromJson(recordAuth.meta);
      final RawUser rawUser = RawUser.fromJson(recordAuth.meta['rawUser']);
      final String influencerId = influencer.id;
      final influencerProfileId = await createInfluencerProfile(
          pocketBase: pb, meta: meta, rawUser: rawUser);

      debugPrint('Created influencer profile');
      await linkProfileWithAccount(
        userId: influencerId,
        profileId: influencerProfileId,
        pb: pb,
        collectionName: 'influencer',
      );
      debugPrint('Linked profile with account');
      return influencer;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  static Future<void> linkProfileWithAccount(
      {required String userId,
      required String profileId,
      required String collectionName,
      required PocketBase pb}) async {
    final body = <String, dynamic>{
      "profile": profileId,
      "onboarded": true,
      "connectedSocial": true,
    };

    await pb.collection(collectionName).update(userId, body: body);
  }

  static Future<void> updateOnboardValue(
      {required String collectionName}) async {
    final pb = await PocketBaseSingleton.instance;
    final id = pb.authStore.record!.id;
    final body = <String, dynamic>{
      "onboarded": true,
    };
    await pb.collection(collectionName).update(id, body: body);
  }

  static Future<String> createInfluencerProfile(
      {required PocketBase pocketBase,
      required Meta meta,
      required RawUser rawUser}) async {
    final body = <String, dynamic>{
      "title": null,
      "description": null,
      "followers": rawUser.followersCount,
      "engRate": null,
      "location": null,
      "mediaCount": rawUser.mediaCount,
      "followings": rawUser.followsCount,
    };

    final record =
        await pocketBase.collection('influencerProfile').create(body: body);
    final String influencerProfileId = record.id;
    return influencerProfileId;
  }

  /// [login] is a method that logs in a user with their email and password.
  static Future<RecordAuth> login(
      {required String email,
      required String password,
      required String accountType}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final authData =
          await pb.collection(accountType).authWithPassword(email, password);

      debugPrint('Logged in as ${authData.record.data['email']}');
      return authData;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// [logout] is a method that logs out the current user.
  static Future<void> logout() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      pb.authStore.clear();
      debugPrint('Logged out');
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// [verifyEmail] is a method that sends a verification email to the user's
  static Future<void> verifyEmail({required String email}) async {
    String collectionName = CollectionNameSingleton.instance;
    try {
      final pb = await PocketBaseSingleton.instance;
      return await pb.collection(collectionName).requestVerification(email);
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
