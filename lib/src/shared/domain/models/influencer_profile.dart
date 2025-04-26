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

  // Create a factory for generating empty profiles with default values
  factory InfluencerProfile.empty({required String id}) => InfluencerProfile(
        id: id,
        collectionId: "influencerProfile",
        collectionName: "influencerProfile",
        description: "",
        mediaCount: 0,
        followers: 0,
        engRate: 0,
        avgInteractions: 0,
        avgLikes: 0,
        avgComments: 0,
        avgVideoLikes: 0,
        avgVideoComments: 0,
        avgVideoViews: 0,
        country: '',
        gender: '',
        created: DateTime.now(),
        updated: DateTime.now(),
      );

  factory InfluencerProfile.fromJson(Map<String, dynamic> json) =>
      InfluencerProfile(
        collectionId: json["collectionId"] ?? "",
        collectionName: json["collectionName"] ?? "",
        id: json["id"] ?? "",
        mediaCount: json["mediaCount"] ?? 0,
        description: json["description"] ?? "",
        followers: json["followers"] ?? 0,
        engRate: json["engRate"] ?? 0,
        avgInteractions: json["avgInteractions"] ?? 0,
        avgLikes: json["avgLikes"] ?? 0,
        avgComments: json["avgComments"] ?? 0,
        avgVideoLikes: json["avgVideoLikes"] ?? 0,
        avgVideoComments: json["avgVideoComments"] ?? 0,
        avgVideoViews: json["avgVideoViews"] ?? 0,
        country: json["country"] ?? '',
        gender: json["gender"] ?? '',
        created: json["created"] != null
            ? DateTime.parse(json["created"])
            : DateTime.now(),
        updated: json["updated"] != null
            ? DateTime.parse(json["updated"])
            : DateTime.now(),
      );

  factory InfluencerProfile.fromRawJson(String str) =>
      InfluencerProfile.fromJson(json.decode(str));

  factory InfluencerProfile.fromRecord(RecordModel record) =>
      InfluencerProfile.fromJson(record.toJson());

  InfluencerProfile copyWith({
    String? collectionId,
    String? collectionName,
    String? id,
    int? mediaCount,
    String? description,
    int? followers,
    int? engRate,
    int? avgInteractions,
    int? avgLikes,
    int? avgComments,
    int? avgVideoLikes,
    int? avgVideoComments,
    int? avgVideoViews,
    String? country,
    String? gender,
    DateTime? created,
    DateTime? updated,
  }) =>
      InfluencerProfile(
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        id: id ?? this.id,
        mediaCount: mediaCount ?? this.mediaCount,
        description: description ?? this.description,
        followers: followers ?? this.followers,
        engRate: engRate ?? this.engRate,
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
        "mediaCount": mediaCount,
        "description": description,
        "followers": followers,
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
