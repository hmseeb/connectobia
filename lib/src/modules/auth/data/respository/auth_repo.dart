import 'package:connectobia/src/db/db.dart';
import 'package:connectobia/src/modules/auth/domain/model/user.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

/// [AuthRepo] is a repository class that contains all the methods that are
/// responsible for handling authentication related operations.
class AuthRepo {
  /// [createAccount] is a method that creates a new user account.
  static Future<RecordModel> createAccount(
      String firstName,
      String lastName,
      String email,
      String website,
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
      "company_website": website,
      "account_type": accountType,
      "industry": industry,
    };

    try {
      final pb = await PocketBaseSingleton.instance;
      RecordModel user = await pb.collection('users').create(body: body);
      await pb.collection('users').requestVerification(email);
      await AuthRepo.login(email, password);
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

      debugPrint('Logged in as ${authData.record!.data['email']}');
      return authData;
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
