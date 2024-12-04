// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  final String id;
  final String collectionId;
  final String collectionName;
  final String username;
  final bool verified;
  final bool emailVisibility;
  final String email;
  final DateTime created;
  final DateTime updated;
  final String firstName;
  final String avatar;
  final String lastName;
  final String accountType;
  final String industry;
  final String banner;
  final String brandName;
  final bool hasCompletedOnboarding;

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
    required this.accountType,
    required this.industry,
    required this.banner,
    required this.brandName,
    required this.hasCompletedOnboarding,
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
        accountType: json["account_type"],
        industry: json["industry"],
        banner: json["banner"],
        brandName: json["brand_name"],
        hasCompletedOnboarding: json["hasCompletedOnboarding"],
      );
  factory User.fromRecord(RecordModel record) => User.fromJson(record.toJson());

  User copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? username,
    bool? verified,
    bool? emailVisibility,
    String? email,
    DateTime? created,
    DateTime? updated,
    String? firstName,
    String? avatar,
    String? lastName,
    String? accountType,
    String? industry,
    String? banner,
    String? brandName,
    bool? hasCompletedOnboarding,
  }) =>
      User(
        id: id ?? this.id,
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        username: username ?? this.username,
        verified: verified ?? this.verified,
        emailVisibility: emailVisibility ?? this.emailVisibility,
        email: email ?? this.email,
        created: created ?? this.created,
        updated: updated ?? this.updated,
        firstName: firstName ?? this.firstName,
        avatar: avatar ?? this.avatar,
        lastName: lastName ?? this.lastName,
        accountType: accountType ?? this.accountType,
        industry: industry ?? this.industry,
        banner: banner ?? this.banner,
        brandName: brandName ?? this.brandName,
        hasCompletedOnboarding:
            hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      );

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
        "account_type": accountType,
        "industry": industry,
        "banner": banner,
        "brand_name": brandName,
        "hasCompletedOnboarding": hasCompletedOnboarding,
      };
}
