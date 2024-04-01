import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Collaboration {
  final String id;
  final String collectionId;
  final String collectionName;
  final String campaign;
  final String brand;
  final String influencer;
  final double proposedAmount;
  final String status;
  final String message;
  final String sendBy;
  final DateTime created;
  final DateTime updated;

  Collaboration({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.campaign,
    required this.brand,
    required this.influencer,
    required this.proposedAmount,
    required this.status,
    required this.message,
    required this.sendBy,
    required this.created,
    required this.updated,
  });

  factory Collaboration.fromJson(Map<String, dynamic> json) {
    return Collaboration(
      id: json["id"],
      collectionId: json["collectionId"],
      collectionName: json["collectionName"],
      campaign: json["campaign"],
      brand: json["brand"],
      influencer: json["influencer"],
      proposedAmount: json["proposed_amount"] != null
          ? (json["proposed_amount"] is int
              ? (json["proposed_amount"] as int).toDouble()
              : json["proposed_amount"] as double)
          : 0.0,
      status: json["status"] ?? "pending",
      message: json["message"] ?? "",
      sendBy: json["send_by"] ?? "",
      created: DateTime.parse(json["created"]),
      updated: DateTime.parse(json["updated"]),
    );
  }

  factory Collaboration.fromRawJson(String str) =>
      Collaboration.fromJson(json.decode(str));

  factory Collaboration.fromRecord(RecordModel record) =>
      Collaboration.fromJson(record.toJson());

  Collaboration copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? campaign,
    String? brand,
    String? influencer,
    double? proposedAmount,
    String? status,
    String? message,
    String? sendBy,
    DateTime? created,
    DateTime? updated,
  }) =>
      Collaboration(
        id: id ?? this.id,
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        campaign: campaign ?? this.campaign,
        brand: brand ?? this.brand,
        influencer: influencer ?? this.influencer,
        proposedAmount: proposedAmount ?? this.proposedAmount,
        status: status ?? this.status,
        message: message ?? this.message,
        sendBy: sendBy ?? this.sendBy,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );

  Map<String, dynamic> toCreateJson() => {
        "campaign": campaign,
        "brand": brand,
        "influencer": influencer,
        "proposed_amount": proposedAmount,
        "status": status,
        "message": message,
        "send_by": sendBy,
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "campaign": campaign,
        "brand": brand,
        "influencer": influencer,
        "proposed_amount": proposedAmount,
        "status": status,
        "message": message,
        "send_by": sendBy,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
