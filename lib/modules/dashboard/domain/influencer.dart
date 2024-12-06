// To parse this JSON data, do
//
//     final influencer = influencerFromJson(jsonString);

import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

Influencer influencerFromJson(String str) =>
    Influencer.fromJson(json.decode(str));

String influencerToJson(Influencer data) => json.encode(data.toJson());

class Expand {
  final User user;

  Expand({
    required this.user,
  });

  factory Expand.fromJson(Map<String, dynamic> json) => Expand(
        user: User.fromJson(json["user"]),
      );

  Expand copyWith({
    User? user,
  }) =>
      Expand(
        user: user ?? this.user,
      );

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
      };
}

class Influencer {
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final String description;
  final Expand expand;
  final String gender;
  final String id;
  final String location;
  final String title;
  final DateTime updated;
  final String user;

  Influencer({
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.description,
    required this.expand,
    required this.gender,
    required this.id,
    required this.location,
    required this.title,
    required this.updated,
    required this.user,
  });

  factory Influencer.fromJson(Map<String, dynamic> json) => Influencer(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: DateTime.parse(json["created"]),
        description: json["description"],
        expand: Expand.fromJson(json["expand"]),
        gender: json["gender"],
        id: json["id"],
        location: json["location"],
        title: json["title"],
        updated: DateTime.parse(json["updated"]),
        user: json["user"],
      );

  factory Influencer.fromRecord(RecordModel record) =>
      Influencer.fromJson(record.toJson());

  Influencer copyWith({
    String? collectionId,
    String? collectionName,
    DateTime? created,
    String? description,
    Expand? expand,
    String? gender,
    String? id,
    String? location,
    String? title,
    DateTime? updated,
    String? user,
  }) =>
      Influencer(
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        created: created ?? this.created,
        description: description ?? this.description,
        expand: expand ?? this.expand,
        gender: gender ?? this.gender,
        id: id ?? this.id,
        location: location ?? this.location,
        title: title ?? this.title,
        updated: updated ?? this.updated,
        user: user ?? this.user,
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created.toIso8601String(),
        "description": description,
        "expand": expand.toJson(),
        "gender": gender,
        "id": id,
        "location": location,
        "title": title,
        "updated": updated.toIso8601String(),
        "user": user,
      };
}

class User {
  final String accountType;
  final String avatar;
  final String banner;
  final String brandName;
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final bool emailVisibility;
  final String fullName;
  final String id;
  final String industry;
  final DateTime updated;
  final String username;
  final bool verified;

  User({
    required this.accountType,
    required this.avatar,
    required this.banner,
    required this.brandName,
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.emailVisibility,
    required this.fullName,
    required this.id,
    required this.industry,
    required this.updated,
    required this.username,
    required this.verified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        accountType: json["account_type"],
        avatar: json["avatar"],
        banner: json["banner"],
        brandName: json["brand_name"],
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: DateTime.parse(json["created"]),
        emailVisibility: json["emailVisibility"],
        fullName: json["full_name"],
        id: json["id"],
        industry: json["industry"],
        updated: DateTime.parse(json["updated"]),
        username: json["username"],
        verified: json["verified"],
      );

  factory User.fromRecord(RecordModel record) => User.fromJson(record.toJson());

  User copyWith({
    String? accountType,
    String? avatar,
    String? banner,
    String? brandName,
    String? collectionId,
    String? collectionName,
    DateTime? created,
    bool? emailVisibility,
    String? fullName,
    String? id,
    String? industry,
    DateTime? updated,
    String? username,
    bool? verified,
  }) =>
      User(
        accountType: accountType ?? this.accountType,
        avatar: avatar ?? this.avatar,
        banner: banner ?? this.banner,
        brandName: brandName ?? this.brandName,
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        created: created ?? this.created,
        emailVisibility: emailVisibility ?? this.emailVisibility,
        fullName: fullName ?? this.fullName,
        id: id ?? this.id,
        industry: industry ?? this.industry,
        updated: updated ?? this.updated,
        username: username ?? this.username,
        verified: verified ?? this.verified,
      );
  Map<String, dynamic> toJson() => {
        "account_type": accountType,
        "avatar": avatar,
        "banner": banner,
        "brand_name": brandName,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created.toIso8601String(),
        "emailVisibility": emailVisibility,
        "full_name": fullName,
        "id": id,
        "industry": industry,
        "updated": updated.toIso8601String(),
        "username": username,
        "verified": verified,
      };
}
