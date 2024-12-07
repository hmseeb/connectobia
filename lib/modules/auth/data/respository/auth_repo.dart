import 'package:connectobia/common/constants/industries.dart';
import 'package:connectobia/common/singletons/account_type.dart';
import 'package:connectobia/db/db.dart';
import 'package:connectobia/modules/auth/domain/model/brand.dart';
import 'package:connectobia/modules/auth/domain/model/influencer.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

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
      // TODO: Find a workaround for this delay
      Future.delayed(const Duration(milliseconds: 1000), () async {
        await AuthRepo.login(
            email: email, password: password, accountType: 'brand');
      });
      debugPrint('Created account for $email');
      return user;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// [createBrandAccount] is a method that creates a new user account.
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
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// [forgotPassword] is a method that sends a password reset email to the
  /// user's email address.
  static Future<void> forgotPassword({required String email}) async {
    final collectionName = CollectionNameSingleton.instance;
    try {
      final pb = await PocketBaseSingleton.instance;
      return await pb.collection(collectionName).requestPasswordReset(email);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<dynamic> getCurrentUser() async {
    PocketBase pocketBase = await PocketBaseSingleton.instance;
    // pocketBase.collection(CollectionNameSingleton.instance).authRefresh();

    try {
      bool isAuthenticated = pocketBase.authStore.isValid;
      if (isAuthenticated) {
        CollectionNameSingleton.instance =
            pocketBase.authStore.record!.collectionName;
        dynamic user = await getUser();
        return user;
      } else {
        pocketBase.authStore.clear();
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// [getUser] is a method that returns the current user's information.
  static Future<dynamic> getUser() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final id = pb.authStore.record!.id;
      String collectionName = CollectionNameSingleton.instance;
      RecordModel record = await pb.collection(collectionName).getOne(id);
      if (collectionName == 'brand') {
        final Brand user = Brand.fromRecord(record);
        return user;
      } else {
        final Influencer user = Influencer.fromRecord(record);
        return user;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// [login] is a method that logs in a user with their email and password.
  static Future<RecordAuth> login(
      {required String email,
      required String password,
      required String accountType}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      CollectionNameSingleton.instance = accountType;
      final authData =
          await pb.collection(accountType).authWithPassword(email, password);

      debugPrint('Logged in as ${authData.record.data['email']}');
      return authData;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///  [loginWithInstagram] is a method that authenticates a user with their Instagram brand account.
  static Future<RecordAuth> loginWithInstagram(
      {required String collectionName}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final user = await pb
          .collection('influencer')
          .authWithOAuth2('instagram2', (url) async {
        await launchUrl(url);
      });
      return user;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// [logout] is a method that logs out the current user.
  static Future<void> logout() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      pb.authStore.clear();
      debugPrint('Logged out');
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// [verifyEmail] is a method that sends a verification email to the user's
  static Future<void> verifyEmail({required String email}) async {
    String collectionName = CollectionNameSingleton.instance;
    try {
      final pb = await PocketBaseSingleton.instance;
      return await pb.collection(collectionName).requestVerification(email);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
