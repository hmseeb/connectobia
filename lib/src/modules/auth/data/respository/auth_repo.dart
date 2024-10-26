import 'package:connectobia/src/db/pb.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthRepo {
  static Future<RecordModel> createAccount(String firstName, String lastName,
      String email, String website, String password, String accountType) async {
    // example create body
    final body = <String, dynamic>{
      "username": email.split('@')[0],
      "email": email,
      "emailVisibility": false, // hide email
      "password": password,
      "passwordConfirm": password,
      "first_name": firstName,
      "last_name": lastName,
      "company_website": website,
      "account_type": accountType,
    };

    try {
      final pb = await PocketBaseSingleton.instance;
      RecordModel user = await pb.collection('users').create(body: body);
      await pb.collection('users').requestVerification(email);
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

  static Future<String> getAccountType() async {
    final pb = await PocketBaseSingleton.instance;
    final id = await getUserID();
    final RecordModel record = await pb.collection('users').getOne(id);
    if (record.data['account_type'] == 'brand') {
      return 'brand';
    } else {
      return 'influencer';
    }
  }

  static Future<String> getUserID() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      return pb.authStore.model.id;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<RecordAuth> login(String email, String password) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final user =
          await pb.collection('users').authWithPassword(email, password);
      return user;
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
