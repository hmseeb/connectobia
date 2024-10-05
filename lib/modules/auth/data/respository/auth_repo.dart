import 'package:connectobia/db/pb.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthRepo {
  static Future<RecordModel> createAccount(String firstName, String lastName,
      String email, String website, String password, String accountType) async {
    // example create body
    final body = <String, dynamic>{
      "email": email,
      "emailVisibility": true,
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
}
