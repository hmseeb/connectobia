import 'dart:convert';

import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/constants/industries.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/data/services/instagram_analytics_service.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:connectobia/src/shared/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

/// [AuthRepo] is a repository class that contains all the methods that are
/// responsible for handling authentication related operations.
///
/// {@category Repositories}
class AuthRepository {
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
      RecordModel user = await pb.collection('brands').create(body: body);
      await pb.collection('brands').requestVerification(email);
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
      RecordModel user = await pb.collection('influencers').create(body: body);
      await pb.collection('influencers').requestVerification(email);
      debugPrint('Created account for $email');
      return user;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  static Future<String> createInfluencerProfileByInstagram(
      {required Meta meta, required RawUser rawUser}) async {
    final pocketBase = await PocketBaseSingleton.instance;

    // Fetch additional analytics data using the Instagram username
    final String username = rawUser.username ?? '';
    Map<String, dynamic> analyticsData = {};

    if (username.isNotEmpty) {
      debugPrint('Fetching additional analytics for $username');
      analyticsData = await InstagramAnalyticsService.getProfileAnalytics(
          username: username);
    }

    final body = <String, dynamic>{
      "followers": rawUser.followersCount,
      "mediaCount": rawUser.mediaCount,
      // Add the additional analytics data
      "avgInteractions": analyticsData['avgInteractions'] ?? 0,
      "avgLikes": analyticsData['avgLikes'] ?? 0,
      "avgComments": analyticsData['avgComments'] ?? 0,
      "avgVideoLikes": analyticsData['avgVideoLikes'] ?? 0,
      "avgVideoComments": analyticsData['avgVideoComments'] ?? 0,
      "avgVideoViews": analyticsData['avgVideoViews'] ?? 0,
      "country": analyticsData['country'] ?? '',
      "gender": analyticsData['gender'] ?? '',
    };

    final record =
        await pocketBase.collection('influencerProfile').create(body: body);
    final String influencerProfileId = record.id;
    return influencerProfileId;
  }

  static Future<void> createLoginHistory({
    required String userId,
    required Map<String, dynamic> deviceInfo,
  }) async {
    final pb = await PocketBaseSingleton.instance;
    final body = <String, dynamic>{
      "userId": userId,
      "deviceInfo": json.encode(deviceInfo),
      "ipAddress": deviceInfo['Public IP'],
      "location": "${deviceInfo['City']}, ${deviceInfo['Country']}",
    };

    await pb.collection('loginHistory').create(body: body);
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
      if (collectionName == 'brands') {
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

  /// [getUserId] is a method that returns the current user's id.
  static Future<dynamic> getUserId() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final id = pb.authStore.record!.id;
      return id;
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  ///  [instagramAuth] is a method that authenticates a user with their Instagram brand account.
  static Future<Influencer> instagramAuth(
      {required String collectionName}) async {
    try {
      debugPrint('Starting Instagram auth process');
      final pb = await PocketBaseSingleton.instance;
      debugPrint('PocketBase instance obtained');

      // Ensure the URL is properly handled
      final recordAuth = await pb
          .collection('influencers')
          .authWithOAuth2('instagram2', (url) async {
        debugPrint('Opening Instagram OAuth URL: $url');
        final result = await launchUrl(url, mode: LaunchMode.inAppWebView);
        debugPrint('URL launch result: $result');
      });

      debugPrint('OAuth2 authentication completed');
      debugPrint(
          'Auth token received: ${pb.authStore.token.substring(0, 15)}...');

      // Verify auth token is still valid
      final isValid = pb.authStore.isValid;
      debugPrint('Auth token valid: $isValid');

      final Influencer influencer = Influencer.fromRecord(recordAuth.record);
      debugPrint('Influencer record created: ${influencer.id}');

      final Meta meta = Meta.fromJson(recordAuth.meta);
      final RawUser rawUser = RawUser.fromJson(recordAuth.meta['rawUser']);
      final String influencerId = influencer.id;
      debugPrint('Instagram username: ${rawUser.username}');

      if (influencer.profile.isEmpty) {
        debugPrint('Creating influencer profile for new Instagram user');
        final influencerProfileId = await createInfluencerProfileByInstagram(
            meta: meta, rawUser: rawUser);

        debugPrint('Created influencer profile with ID: $influencerProfileId');
        await linkProfileWithAccount(
          userId: influencerId,
          profileId: influencerProfileId,
          pb: pb,
          collectionName: 'influencers',
        );
        debugPrint('Linked profile with account');
      } else {
        debugPrint('User already has a profile: ${influencer.profile}');
      }
      return influencer;
    } catch (e) {
      debugPrint('Instagram auth error: $e');
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

  /// [login] is a method that logs in a user with their email and password.
  static Future<RecordAuth> login(
      {required String email,
      required String password,
      required String accountType}) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      // Unsubscribe from all realtime connections before login
      // This prevents auth token mismatch errors
      await PocketBaseSingleton.unsubscribeAll();

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

      // Unsubscribe from all realtime connections before logout
      await PocketBaseSingleton.unsubscribeAll();

      pb.authStore.clear();
      debugPrint('Logged out successfully');
    } catch (e) {
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// [requestEmailChange] is a method that sends an email change request to the user's
  /// email address. This will send a verification email to the new email address.
  static Future<void> requestEmailChange({required String newEmail}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      if (!pb.authStore.isValid) {
        throw Exception("You must be logged in to change your email");
      }

      final String collectionName = pb.authStore.record!.collectionName;
      final String userId = pb.authStore.record!.id;

      debugPrint(
          'Requesting email change to $newEmail for user $userId in collection $collectionName');

      // Request the email change - this is the correct and simplest way to do it
      return await pb.collection(collectionName).requestEmailChange(newEmail);
    } catch (e) {
      debugPrint('Email change error: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
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
