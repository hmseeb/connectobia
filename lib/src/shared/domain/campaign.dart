import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';

class Campaign {
  final String collectionId;
  final String collectionName;
  final String id;
  final String title;
  final String description;
  final double rating;
  final String distance;
  final String price;
  final DateTime created;
  final DateTime updated;

  Campaign({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.distance,
    required this.price,
    required this.created,
    required this.updated,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        id: json["id"],
        title: json["title"],
        description: json["description"] ?? "",
        rating: (json["rating"] as num).toDouble(),
        distance: json["distance"] ?? "",
        price: json["price"] ?? "",
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
      );

  factory Campaign.fromRawJson(String str) => Campaign.fromJson(json.decode(str));

  factory Campaign.fromRecord(RecordModel record) =>
      Campaign.fromJson(record.toJson());

  Campaign copyWith({
    String? collectionId,
    String? collectionName,
    String? id,
    String? title,
    String? description,
    double? rating,
    String? distance,
    String? price,
    DateTime? created,
    DateTime? updated,
  }) =>
      Campaign(
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        rating: rating ?? this.rating,
        distance: distance ?? this.distance,
        price: price ?? this.price,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "title": title,
        "description": description,
        "rating": rating,
        "distance": distance,
        "price": price,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
