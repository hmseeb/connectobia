// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

@JsonSerializable()

/// User is a class that represents a user in the application.
///
/// This class is used to store the user's information such as their id, username,
/// email, and other details. This class is used to maintain the user's information
/// throughout the application.
///
/// {@category Models}
class User {
  String id;
  String collectionId;
  String collectionName;
  String username;
  bool verified;
  bool emailVisibility;
  String email;
  DateTime created;
  DateTime updated;
  String firstName;
  String avatar;
  String lastName;
  String brandName;
  String accountType;

  User({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.username,
    required this.verified,
    required this.emailVisibility,
    required this.email,
    required this.created,
    required this.updated,
    required this.firstName,
    required this.avatar,
    required this.lastName,
    required this.brandName,
    required this.accountType,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        username: json["username"],
        verified: json["verified"],
        emailVisibility: json["emailVisibility"],
        email: json["email"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
        firstName: json["first_name"],
        avatar: json["avatar"],
        lastName: json["last_name"],
        brandName: json["brand_name"],
        accountType: json["account_type"],
      );

  factory User.fromRecord(RecordModel record) => User.fromJson(record.toJson());

  Map<String, dynamic> toJson() => {
        "id": id,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "username": username,
        "verified": verified,
        "emailVisibility": emailVisibility,
        "email": email,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
        "first_name": firstName,
        "avatar": avatar,
        "last_name": lastName,
        "brand_name": brandName,
        "account_type": accountType,
      };
}