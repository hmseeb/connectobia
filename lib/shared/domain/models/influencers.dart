import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

import 'influencer.dart';

class Influencers {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<Influencer> items;

  Influencers({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });

  factory Influencers.fromJson(Map<String, dynamic> json) => Influencers(
        page: json["page"],
        perPage: json["perPage"],
        totalPages: json["totalPages"],
        totalItems: json["totalItems"],
        items: List<Influencer>.from(
            json["items"].map((x) => Influencer.fromJson(x))),
      );

  factory Influencers.fromRawJson(String str) =>
      Influencers.fromJson(json.decode(str));

  factory Influencers.fromRecord(ResultList<RecordModel> record) =>
      Influencers.fromJson(record.toJson());

  Influencers copyWith({
    int? page,
    int? perPage,
    int? totalPages,
    int? totalItems,
    List<Influencer>? items,
  }) =>
      Influencers(
        page: page ?? this.page,
        perPage: perPage ?? this.perPage,
        totalPages: totalPages ?? this.totalPages,
        totalItems: totalItems ?? this.totalItems,
        items: items ?? this.items,
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "perPage": perPage,
        "totalPages": totalPages,
        "totalItems": totalItems,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };

  String toRawJson() => json.encode(toJson());
}
