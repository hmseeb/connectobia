import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class BrandProfile {
  final String collectionId;
  final String collectionName;
  final String id;
  final String description;
  final DateTime created;
  final DateTime updated;

  BrandProfile({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.description,
    required this.created,
    required this.updated,
  });

  // Create a factory for generating empty profiles with default values
  factory BrandProfile.empty({required String id}) => BrandProfile(
        id: id,
        collectionId: "brandProfile",
        collectionName: "brandProfile",
        description: "",
        created: DateTime.now(),
        updated: DateTime.now(),
      );

  factory BrandProfile.fromJson(Map<String, dynamic> json) => BrandProfile(
        collectionId: json["collectionId"] ?? "",
        collectionName: json["collectionName"] ?? "",
        id: json["id"] ?? "",
        description: json["description"] ?? "",
        created: json["created"] != null
            ? DateTime.parse(json["created"])
            : DateTime.now(),
        updated: json["updated"] != null
            ? DateTime.parse(json["updated"])
            : DateTime.now(),
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
    DateTime? created,
    DateTime? updated,
  }) =>
      BrandProfile(
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        id: id ?? this.id,
        description: description ?? this.description,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "description": description,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
