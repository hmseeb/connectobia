import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Influencer {
  final String collectionId;
  final String collectionName;
  final String id;
  final String? email;
  final bool emailVisibility;
  final bool verified;
  final bool connectedSocial;
  final String fullName;
  final String username;
  final bool onboarded;
  final String? industry;
  final String profile;
  final DateTime created;
  final DateTime updated;

  Influencer({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.email,
    required this.emailVisibility,
    required this.verified,
    required this.fullName,
    required this.username,
    required this.connectedSocial,
    required this.onboarded,
    required this.industry,
    required this.profile,
    required this.created,
    required this.updated,
  });

  factory Influencer.fromJson(Map<String, dynamic> json) => Influencer(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        id: json["id"],
        email: json["email"],
        emailVisibility: json["emailVisibility"],
        verified: json["verified"],
        fullName: json["fullName"],
        username: json["username"],
        onboarded: json["onboarded"],
        connectedSocial: json["connectedSocial"],
        industry: json["industry"],
        profile: json["profile"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
      );

  factory Influencer.fromRawJson(String str) =>
      Influencer.fromJson(json.decode(str));

  factory Influencer.fromRecord(RecordModel record) =>
      Influencer.fromJson(record.toJson());

  Influencer copyWith({
    String? collectionId,
    String? collectionName,
    String? id,
    String? email,
    bool? emailVisibility,
    bool? verified,
    bool? connectedSocial,
    String? fullName,
    String? username,
    bool? onboarded,
    String? industry,
    String? profile,
    DateTime? created,
    DateTime? updated,
  }) =>
      Influencer(
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        id: id ?? this.id,
        email: email ?? this.email,
        emailVisibility: emailVisibility ?? this.emailVisibility,
        verified: verified ?? this.verified,
        fullName: fullName ?? this.fullName,
        username: username ?? this.username,
        onboarded: onboarded ?? this.onboarded,
        connectedSocial: connectedSocial ?? this.connectedSocial,
        industry: industry ?? this.industry,
        profile: profile ?? this.profile,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "email": email,
        "emailVisibility": emailVisibility,
        "verified": verified,
        "fullName": fullName,
        "username": username,
        "connectedSocial": connectedSocial,
        "onboarded": onboarded,
        "industry": industry,
        "profile": profile,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
