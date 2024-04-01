import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Contract {
  final String id;
  final String collectionId;
  final String collectionName;
  final String campaign;
  final String brand;
  final String influencer;
  final List<String> postType;
  final DateTime deliveryDate;
  final double payout;
  final String terms;
  final bool isSignedByBrand;
  final bool isSignedByInfluencer;
  final String status;
  final DateTime created;
  final DateTime updated;

  Contract({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.campaign,
    required this.brand,
    required this.influencer,
    required this.postType,
    required this.deliveryDate,
    required this.payout,
    required this.terms,
    required this.isSignedByBrand,
    required this.isSignedByInfluencer,
    required this.status,
    required this.created,
    required this.updated,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json["id"],
      collectionId: json["collectionId"],
      collectionName: json["collectionName"],
      campaign: json["campaign"],
      brand: json["brand"],
      influencer: json["influencer"],
      postType: json["post_type"] != null
          ? List<String>.from(json["post_type"])
          : ["post"],
      deliveryDate: json["delivery_date"] != null
          ? DateTime.parse(json["delivery_date"])
          : DateTime.now().add(const Duration(days: 14)),
      payout: json["payout"] != null
          ? (json["payout"] is int
              ? (json["payout"] as int).toDouble()
              : json["payout"] as double)
          : 0.0,
      terms: json["terms"] ?? "",
      isSignedByBrand: json["is_signed_by_brand"] ?? false,
      isSignedByInfluencer: json["is_signed_by_influencer"] ?? false,
      status: json["status"] ?? "pending",
      created: DateTime.parse(json["created"]),
      updated: DateTime.parse(json["updated"]),
    );
  }

  factory Contract.fromRawJson(String str) =>
      Contract.fromJson(json.decode(str));

  factory Contract.fromRecord(RecordModel record) =>
      Contract.fromJson(record.toJson());

  Contract copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? campaign,
    String? brand,
    String? influencer,
    List<String>? postType,
    DateTime? deliveryDate,
    double? payout,
    String? terms,
    bool? isSignedByBrand,
    bool? isSignedByInfluencer,
    String? status,
    DateTime? created,
    DateTime? updated,
  }) =>
      Contract(
        id: id ?? this.id,
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        campaign: campaign ?? this.campaign,
        brand: brand ?? this.brand,
        influencer: influencer ?? this.influencer,
        postType: postType ?? this.postType,
        deliveryDate: deliveryDate ?? this.deliveryDate,
        payout: payout ?? this.payout,
        terms: terms ?? this.terms,
        isSignedByBrand: isSignedByBrand ?? this.isSignedByBrand,
        isSignedByInfluencer: isSignedByInfluencer ?? this.isSignedByInfluencer,
        status: status ?? this.status,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );

  Map<String, dynamic> toCreateJson() => {
        "campaign": campaign,
        "brand": brand,
        "influencer": influencer,
        "post_type": postType,
        "delivery_date": deliveryDate.toIso8601String(),
        "payout": payout,
        "terms": terms,
        "is_signed_by_brand": isSignedByBrand,
        "is_signed_by_influencer": isSignedByInfluencer,
        "status": status,
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "campaign": campaign,
        "brand": brand,
        "influencer": influencer,
        "post_type": postType,
        "delivery_date": deliveryDate.toIso8601String(),
        "payout": payout,
        "terms": terms,
        "is_signed_by_brand": isSignedByBrand,
        "is_signed_by_influencer": isSignedByInfluencer,
        "status": status,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
