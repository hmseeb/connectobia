import 'dart:convert';

import 'package:flutter/material.dart' show RangeValues;
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

  /// Advanced filtering with multiple criteria
  Influencers advancedFilterInfluencers({
    String textFilter = '',
    RangeValues? followerRange,
    RangeValues? engagementRange,
    String? country,
    String? gender,
  }) {
    List<Influencer> filteredItems = items;

    // Apply text filter
    if (textFilter.isNotEmpty) {
      filteredItems = filteredItems.where((influencer) {
        return influencer.fullName
                .toLowerCase()
                .contains(textFilter.toLowerCase()) ||
            influencer.industry
                .toLowerCase()
                .contains(textFilter.toLowerCase());
      }).toList();
    }

    // Apply country filter
    if (country != null && country.isNotEmpty) {
      // Note: This is a placeholder. In a real implementation, you would filter
      // based on the influencer's profile data which contains the country field.
      // Currently, the Influencer model doesn't have a country field directly.
    }

    // Apply gender filter
    if (gender != null && gender.isNotEmpty) {
      // Note: This is a placeholder. In a real implementation, you would filter
      // based on the influencer's profile data which contains the gender field.
    }

    return Influencers(
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      totalItems: filteredItems.length,
      items: filteredItems,
    );
  }

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

  Influencers filterInfluencers(String filter) {
    // Simple text-based filter
    List<Influencer> filteredItems = items.where((influencer) {
      return influencer.fullName.toLowerCase().contains(filter.toLowerCase()) ||
          influencer.industry.toLowerCase().contains(filter.toLowerCase());
    }).toList();
    return Influencers(
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      totalItems: filteredItems.length,
      items: filteredItems,
    );
  }

  Map<String, dynamic> toJson() => {
        "page": page,
        "perPage": perPage,
        "totalPages": totalPages,
        "totalItems": totalItems,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };

  String toRawJson() => json.encode(toJson());
}
