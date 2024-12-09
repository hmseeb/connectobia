import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class InfluencerProfile {
  final String collectionId;
  final String collectionName;
  final String id;
  final String title;
  final String description;
  final int followers;
  final int engRate;
  final int mediaCount;
  final String location;
  final DateTime created;
  final DateTime updated;

  InfluencerProfile({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.title,
    required this.description,
    required this.mediaCount,
    required this.followers,
    required this.engRate,
    required this.location,
    required this.created,
    required this.updated,
  });

  factory InfluencerProfile.fromJson(Map<String, dynamic> json) =>
      InfluencerProfile(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        id: json["id"],
        title: json["title"],
        mediaCount: json["mediaCount"],
        description: json["description"],
        followers: json["followers"],
        engRate: json["engRate"],
        location: json["location"],
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
    String? location,
    String? avatar,
    String? banner,
    DateTime? created,
    DateTime? updated,
  }) =>
      InfluencerProfile(
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        followers: followers ?? this.followers,
        engRate: engRate ?? this.engRate,
        mediaCount: mediaCount ?? this.mediaCount,
        location: location ?? this.location,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "title": title,
        "description": description,
        "followers": followers,
        "mediaCount": mediaCount,
        "engRate": engRate,
        "location": location,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
