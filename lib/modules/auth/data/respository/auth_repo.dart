import 'package:connectobia/db/db.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

/// [AuthRepo] is a repository class that contains all the methods that are
/// responsible for handling authentication related operations.
///
/// {@category Repositories}
class AuthRepo {
  /// [createAccount] is a method that creates a new user account.
  static Future<RecordModel> createAccount(
      String firstName,
      String lastName,
      String username,
      String email,
      String brandName,
      String password,
      String accountType,
      String industry) async {
    final body = <String, dynamic>{
      // "username": email.split('@')[0],
      "email": email,
      "emailVisibility": false, // hide email
      "password": password,
      "passwordConfirm": password,
      "first_name": firstName,
      "last_name": lastName,
      "username": username,
      "brand_name": brandName,
      "account_type": accountType,
      "industry": industry,
    };

    try {
      final pb = await PocketBaseSingleton.instance;
      RecordModel user = await pb.collection('users').create(body: body);
      await pb.collection('users').requestVerification(email);

      // TODO: Find a workaround for this delay
      Future.delayed(const Duration(milliseconds: 1000), () async {
        await AuthRepo.login(email, password);
      });
      debugPrint('Created account for $email');

      if (accountType == 'influencer') {
        String id = user.id;
        final body = <String, dynamic>{
          "user": id,
        };
        await pb.collection('influencers').create(body: body);
      }
      return user;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// [forgotPassword] is a method that sends a password reset email to the
  /// user's email address.
  static Future<void> forgotPassword(String email) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      return await pb.collection('users').requestPasswordReset(email);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<User?> getCurrentUser() async {
    PocketBase pocketBase = await PocketBaseSingleton.instance;
    bool isAuthenticated = pocketBase.authStore.isValid;
    if (isAuthenticated) {
      try {
        User user = await AuthRepo.getUser();
        return user;
      } catch (e) {
        debugPrint(e.toString());
        rethrow;
      }
    } else {
      pocketBase.authStore.clear();
    }
    return null;
  }

  /// [getUser] is a method that returns the current user's information.
  static Future<User> getUser() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final id = pb.authStore.model.id;
      RecordModel record = await pb.collection('users').getOne(id);
      User user = User.fromRecord(record);
      return user;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// [login] is a method that logs in a user with their email and password.
  static Future<RecordAuth> login(String email, String password) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final authData =
          await pb.collection('users').authWithPassword(email, password);

      debugPrint('Logged in as ${authData.record.data['email']}');
      return authData;
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
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// [verifyEmail] is a method that sends a verification email to the user's
  static Future<void> verifyEmail(String email) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      return await pb.collection('users').requestVerification(email);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
