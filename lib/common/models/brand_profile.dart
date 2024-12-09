import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class BrandProfile {
  final String collectionId;
  final String collectionName;
  final String id;
  final String title;
  final String description;
  final String links;
  final DateTime created;
  final DateTime updated;

  BrandProfile({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.title,
    required this.description,
    required this.links,
    required this.created,
    required this.updated,
  });

  factory BrandProfile.fromJson(Map<String, dynamic> json) => BrandProfile(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        id: json["id"],
        title: json["title"],
        description: json["description"],
        links: json["links"] ?? '',
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
      );

  factory BrandProfile.fromRawJson(String str) =>
      BrandProfile.fromJson(json.decode(str));

  factory BrandProfile.fromRecord(RecordModel record) =>
      BrandProfile.fromJson(record.toJson());

  BrandProfile copyWith({
    String? collectionId,
    String? collectionName,
    String? id,
    String? title,
    String? description,
    String? links,
    DateTime? created,
    DateTime? updated,
  }) =>
      BrandProfile(
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        links: links ?? this.links,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "title": title,
        "description": description,
        "links": links,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
