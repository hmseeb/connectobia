import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show RangeValues;
import 'package:pocketbase/pocketbase.dart';

import '../../../modules/dashboard/common/data/repositories/profile_repo.dart';
import 'influencer.dart';
import 'influencer_profile.dart';

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

  /// Advanced filtering with multiple criteria - synchronous version for UI preview
  Influencers advancedFilterInfluencers({
    String textFilter = '',
    required Map<String, RangeValues> rangeFilters,
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

    // When no range filters are applied, just return text-filtered results
    if (rangeFilters.isEmpty) {
      return Influencers(
        page: page,
        perPage: perPage,
        totalPages: totalPages,
        totalItems: filteredItems.length,
        items: filteredItems,
      );
    }

    // For the synchronous version, we'll log that filters are applied but can't load profiles
    debugPrint(
        'Range filters applied but profiles need to be loaded asynchronously');
    debugPrint('Applied filters: ${rangeFilters.keys.join(', ')}');

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

  /// Filter influencers by a list of IDs
  Influencers filterByIds(List<String> ids) {
    // Return all influencers whose IDs are in the provided list
    List<Influencer> filteredItems = items.where((influencer) {
      return ids.contains(influencer.id);
    }).toList();

    return Influencers(
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      totalItems: filteredItems.length,
      items: filteredItems,
    );
  }

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

  /// Advanced filtering with asynchronous profile loading
  /// This should be called from the BrandDashboardBloc
  static Future<Influencers> advancedFilterWithProfiles({
    required Influencers source,
    String textFilter = '',
    required Map<String, RangeValues> rangeFilters,
  }) async {
    List<Influencer> filteredItems = source.items;

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

    // When no range filters are applied, just return text-filtered results
    if (rangeFilters.isEmpty) {
      return Influencers(
        page: source.page,
        perPage: source.perPage,
        totalPages: source.totalPages,
        totalItems: filteredItems.length,
        items: filteredItems,
      );
    }

    // Influencers that pass all filters
    List<Influencer> passedFilters = [];

    // Load profiles and apply filters
    for (final influencer in filteredItems) {
      if (influencer.profile.isNotEmpty) {
        try {
          // Load profile data for this influencer
          final InfluencerProfile profile =
              await ProfileRepository.getInfluencerProfile(
                  profileId: influencer.profile);

          // Check if the profile passes all filters
          bool passesAllFilters = true;

          // Apply each filter
          if (rangeFilters.containsKey('followers')) {
            final range = rangeFilters['followers']!;
            if (profile.followers < range.start ||
                profile.followers > range.end) {
              passesAllFilters = false;
            }
          }

          if (passesAllFilters && rangeFilters.containsKey('engRate')) {
            final range = rangeFilters['engRate']!;
            if (profile.engRate < range.start || profile.engRate > range.end) {
              passesAllFilters = false;
            }
          }

          if (passesAllFilters && rangeFilters.containsKey('mediaCount')) {
            final range = rangeFilters['mediaCount']!;
            if (profile.mediaCount < range.start ||
                profile.mediaCount > range.end) {
              passesAllFilters = false;
            }
          }

          if (passesAllFilters && rangeFilters.containsKey('avgInteractions')) {
            final range = rangeFilters['avgInteractions']!;
            if (profile.avgInteractions < range.start ||
                profile.avgInteractions > range.end) {
              passesAllFilters = false;
            }
          }

          if (passesAllFilters && rangeFilters.containsKey('avgLikes')) {
            final range = rangeFilters['avgLikes']!;
            if (profile.avgLikes < range.start ||
                profile.avgLikes > range.end) {
              passesAllFilters = false;
            }
          }

          if (passesAllFilters && rangeFilters.containsKey('avgComments')) {
            final range = rangeFilters['avgComments']!;
            if (profile.avgComments < range.start ||
                profile.avgComments > range.end) {
              passesAllFilters = false;
            }
          }

          if (passesAllFilters && rangeFilters.containsKey('avgVideoLikes')) {
            final range = rangeFilters['avgVideoLikes']!;
            if (profile.avgVideoLikes < range.start ||
                profile.avgVideoLikes > range.end) {
              passesAllFilters = false;
            }
          }

          if (passesAllFilters &&
              rangeFilters.containsKey('avgVideoComments')) {
            final range = rangeFilters['avgVideoComments']!;
            if (profile.avgVideoComments < range.start ||
                profile.avgVideoComments > range.end) {
              passesAllFilters = false;
            }
          }

          if (passesAllFilters && rangeFilters.containsKey('avgVideoViews')) {
            final range = rangeFilters['avgVideoViews']!;
            if (profile.avgVideoViews < range.start ||
                profile.avgVideoViews > range.end) {
              passesAllFilters = false;
            }
          }

          // If passed all filters, add to the result list
          if (passesAllFilters) {
            passedFilters.add(influencer);
            debugPrint('Influencer ${influencer.fullName} passed all filters');
          }
        } catch (e) {
          debugPrint('Error loading profile for ${influencer.fullName}: $e');
          // Don't include influencers with errors in their profiles
        }
      }
    }

    return Influencers(
      page: source.page,
      perPage: source.perPage,
      totalPages: source.totalPages,
      totalItems: passedFilters.length,
      items: passedFilters,
    );
  }
}
