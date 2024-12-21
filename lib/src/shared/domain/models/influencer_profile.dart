import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class InfluencerProfile {
  final String collectionId;
  final String collectionName;
  final String id;
  final String description;
  final int followers;
  final int engRate;
  final int mediaCount;
  final DateTime created;
  final DateTime updated;

  InfluencerProfile({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.description,
    required this.mediaCount,
    required this.followers,
    required this.engRate,
    required this.created,
    required this.updated,
  });

  factory InfluencerProfile.fromJson(Map<String, dynamic> json) =>
      InfluencerProfile(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        id: json["id"],
        mediaCount: json["mediaCount"],
        description: json["description"],
        followers: json["followers"],
        engRate: json["engRate"] ?? 0,
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
      );

  factory InfluencerProfile.fromRawJson(String str) =>
      InfluencerProfile.fromJson(json.decode(str));

  factory InfluencerProfile.fromRecord(RecordModel record) =>
      InfluencerProfile.fromJson(record.toJson());

  InfluencerProfile copyWith({
    String? collectionId,
    String? collectionName,
    String? id,
    String? title,
    String? description,
    int? followers,
    int? engRate,
    int? mediaCount,
    String? avatar,
    String? banner,
    DateTime? created,
    DateTime? updated,
  }) =>
      InfluencerProfile(
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        id: id ?? this.id,
        description: description ?? this.description,
        followers: followers ?? this.followers,
        engRate: engRate ?? this.engRate,
        mediaCount: mediaCount ?? this.mediaCount,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "description": description,
        "followers": followers,
        "mediaCount": mediaCount,
        "engRate": engRate,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
