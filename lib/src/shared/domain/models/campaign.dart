import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Campaign {
  final String collectionId;
  final String collectionName;
  final String id;
  final String title;
  final String description;
  final List<String> goals;
  final String category;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String brand;
  final String? selectedInfluencer;
  final DateTime created;
  final DateTime updated;

  Campaign({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.title,
    required this.description,
    required this.goals,
    required this.category,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.brand,
    this.selectedInfluencer,
    required this.created,
    required this.updated,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final defaultEndDate = now.add(const Duration(days: 30));

    return Campaign(
      collectionId: json["collectionId"],
      collectionName: json["collectionName"],
      id: json["id"],
      title: json["title"],
      description: json["description"] ?? "",
      goals: json["goals"] != null
          ? List<String>.from(json["goals"])
          : ["awareness"],
      category: json["category"] ?? "fashion",
      budget: json["budget"] != null
          ? (json["budget"] is int
              ? (json["budget"] as int).toDouble()
              : json["budget"] as double)
          : 0.0,
      startDate:
          json["start_date"] != null ? DateTime.parse(json["start_date"]) : now,
      endDate: json["end_date"] != null
          ? DateTime.parse(json["end_date"])
          : (json["delivery_date"] != null // For backward compatibility
              ? DateTime.parse(json["delivery_date"])
              : defaultEndDate),
      status: json["status"] ?? "draft",
      brand: json["brand"] ?? "",
      selectedInfluencer: json["selected_influencer"],
      created: DateTime.parse(json["created"]),
      updated: DateTime.parse(json["updated"]),
    );
  }

  factory Campaign.fromRawJson(String str) =>
      Campaign.fromJson(json.decode(str));

  factory Campaign.fromRecord(RecordModel record) =>
      Campaign.fromJson(record.toJson());

  // Backward compatibility - provide deliveryDate getter that returns endDate
  DateTime get deliveryDate => endDate;

  Campaign copyWith({
    String? collectionId,
    String? collectionName,
    String? id,
    String? title,
    String? description,
    List<String>? goals,
    String? category,
    double? budget,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? brand,
    String? selectedInfluencer,
    DateTime? created,
    DateTime? updated,
  }) =>
      Campaign(
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        goals: goals ?? this.goals,
        category: category ?? this.category,
        budget: budget ?? this.budget,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        brand: brand ?? this.brand,
        selectedInfluencer: selectedInfluencer ?? this.selectedInfluencer,
        created: created ?? this.created,
        updated: updated ?? this.updated,
      );

  // Helper method to create a new campaign for submission to PocketBase
  Map<String, dynamic> toCreateJson() => {
        "title": title,
        "description": description,
        "goals": goals,
        "category": category,
        "budget": budget,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "status": status,
        "brand": brand,
        "selected_influencer": selectedInfluencer,
      };

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "title": title,
        "description": description,
        "goals": goals,
        "category": category,
        "budget": budget,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "status": status,
        "brand": brand,
        "selected_influencer": selectedInfluencer,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
