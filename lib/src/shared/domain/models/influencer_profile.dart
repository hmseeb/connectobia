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
  final int avgInteractions;
  final int avgLikes;
  final int avgComments;
  final int avgVideoLikes;
  final int avgVideoComments;
  final int avgVideoViews;
  final String country;
  final String gender;
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
    this.avgInteractions = 0,
    this.avgLikes = 0,
    this.avgComments = 0,
    this.avgVideoLikes = 0,
    this.avgVideoComments = 0,
    this.avgVideoViews = 0,
    this.country = '',
    this.gender = '',
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
        avgInteractions: json["avgInteractions"] ?? 0,
        avgLikes: json["avgLikes"] ?? 0,
        avgComments: json["avgComments"] ?? 0,
        avgVideoLikes: json["avgVideoLikes"] ?? 0,
        avgVideoComments: json["avgVideoComments"] ?? 0,
        avgVideoViews: json["avgVideoViews"] ?? 0,
        country: json["country"] ?? '',
        gender: json["gender"] ?? '',
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
    int? avgInteractions,
    int? avgLikes,
    int? avgComments,
    int? avgVideoLikes,
    int? avgVideoComments,
    int? avgVideoViews,
    String? country,
    String? gender,
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
        avgInteractions: avgInteractions ?? this.avgInteractions,
        avgLikes: avgLikes ?? this.avgLikes,
        avgComments: avgComments ?? this.avgComments,
        avgVideoLikes: avgVideoLikes ?? this.avgVideoLikes,
        avgVideoComments: avgVideoComments ?? this.avgVideoComments,
        avgVideoViews: avgVideoViews ?? this.avgVideoViews,
        country: country ?? this.country,
        gender: gender ?? this.gender,
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
        "avgInteractions": avgInteractions,
        "avgLikes": avgLikes,
        "avgComments": avgComments,
        "avgVideoLikes": avgVideoLikes,
        "avgVideoComments": avgVideoComments,
        "avgVideoViews": avgVideoViews,
        "country": country,
        "gender": gender,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
