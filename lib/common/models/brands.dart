import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Brands {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<Item> items;

  Brands({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });
  factory Brands.fromJson(Map<String, dynamic> json) => Brands(
        page: json["page"],
        perPage: json["perPage"],
        totalPages: json["totalPages"],
        totalItems: json["totalItems"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  factory Brands.fromRawJson(String str) => Brands.fromJson(json.decode(str));

  factory Brands.fromRecord(RecordModel record) =>
      Brands.fromJson(record.toJson());

  Brands copyWith({
    int? page,
    int? perPage,
    int? totalPages,
    int? totalItems,
    List<Item>? items,
  }) =>
      Brands(
        page: page ?? this.page,
        perPage: perPage ?? this.perPage,
        totalPages: totalPages ?? this.totalPages,
        totalItems: totalItems ?? this.totalItems,
        items: items ?? this.items,
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "perPage": perPage,
        "totalPages": totalPages,
        "totalItems": totalItems,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };

  String toRawJson() => json.encode(toJson());
}

class Item {
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

  Item({
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

  factory Item.fromJson(Map<String, dynamic> json) => Item(
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

  factory Item.fromRawJson(String str) => Item.fromJson(json.decode(str));

  Item copyWith({
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
      Item(
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
