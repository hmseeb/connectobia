import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Brand {
  final String collectionId;
  final String collectionName;
  final String id;
  final String email;
  final bool emailVisibility;
  final bool verified;
  final String brandName;
  final bool onboarded;
  final String industry;
  final String profile;
  final DateTime created;
  final DateTime updated;

  Brand({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.email,
    required this.emailVisibility,
    required this.verified,
    required this.brandName,
    required this.onboarded,
    required this.industry,
    required this.profile,
    required this.created,
    required this.updated,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        id: json["id"],
        email: json["email"],
        emailVisibility: json["emailVisibility"],
        verified: json["verified"],
        brandName: json["brandName"],
        onboarded: json["onboarded"],
        industry: json["industry"],
        profile: json["profile"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
      );

  factory Brand.fromRawJson(String str) => Brand.fromJson(json.decode(str));

  factory Brand.fromRecord(RecordModel record) =>
      Brand.fromJson(record.toJson());

  Brand copyWith({
    String? collectionId,
    String? collectionName,
    String? id,
    String? email,
    bool? emailVisibility,
    bool? verified,
    String? brandName,
    bool? onboarded,
    String? industry,
    String? profile,
    DateTime? created,
    DateTime? updated,
  }) =>
      Brand(
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        id: id ?? this.id,
        email: email ?? this.email,
        emailVisibility: emailVisibility ?? this.emailVisibility,
        verified: verified ?? this.verified,
        brandName: brandName ?? this.brandName,
        onboarded: onboarded ?? this.onboarded,
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
        "brandName": brandName,
        "onboarded": onboarded,
        "industry": industry,
        "profile": profile,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}