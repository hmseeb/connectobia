import 'package:connectobia/src/db/db.dart';
import 'package:connectobia/src/modules/auth/domain/model/user.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthRepo {
  static Future<RecordModel> createAccount(
      String firstName,
      String lastName,
      String email,
      String website,
      String password,
      String accountType,
      String industry) async {
    // example create body
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

  static Future<void> forgotPassword(String email) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      return await pb.collection('users').requestPasswordReset(email);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  // get user
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
