// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

@JsonSerializable()
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
  String companyWebsite;
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
    required this.companyWebsite,
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
        companyWebsite: json["company_website"],
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
        "company_website": companyWebsite,
        "account_type": accountType,
      };
}
