import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

class Contract {
  final String id;
  final String campaign;
  final String brand;
  final String influencer;
  final List<String> postType;
  final DateTime deliveryDate;
  final double payout;
  final String terms;
  final String guidelines;
  final bool isSignedByBrand;
  final bool isSignedByInfluencer;
  final String status; // pending, signed, rejected, completed
  final String? postUrl; // For storing submitted post URLs as JSON

  // Optional expanded records
  final dynamic campaignRecord;
  final dynamic brandRecord;
  final dynamic influencerRecord;

  Contract({
    required this.id,
    required this.campaign,
    required this.brand,
    required this.influencer,
    required this.postType,
    required this.deliveryDate,
    required this.payout,
    required this.terms,
    this.guidelines = '',
    required this.isSignedByBrand,
    required this.isSignedByInfluencer,
    required this.status,
    this.postUrl,
    this.campaignRecord,
    this.brandRecord,
    this.influencerRecord,
  });

  factory Contract.fromRecord(RecordModel record) {
    final List<dynamic> postTypeList = record.data['post_type'] ?? [];

    // Parse date safely
    DateTime deliveryDate;
    try {
      deliveryDate = DateTime.parse(record.data['delivery_date']);
    } catch (e) {
      deliveryDate = DateTime.now().add(const Duration(days: 7));
    }

    // Parse post_url - Fix to correctly use the 'postUrls' field from the database
    String? postUrl;
    var rawPostUrls = record.data['postUrls'];

    // Handle different types for postUrls with improved logging
    debugPrint(
        'RECEIVED postUrls from DB: $rawPostUrls (${rawPostUrls?.runtimeType})');

    if (rawPostUrls != null) {
      if (rawPostUrls is List) {
        // If it's already a list, convert it to JSON string
        try {
          postUrl = jsonEncode(rawPostUrls);
          debugPrint('CONTRACT MODEL: Converted List to JSON string: $postUrl');
        } catch (e) {
          debugPrint('ERROR encoding list to JSON: $e');
          // Fallback to comma-separated string
          postUrl = rawPostUrls.join(', ');
        }
      } else if (rawPostUrls is String) {
        // If it's already a string, check if it's a valid JSON string
        try {
          // Try to decode and re-encode to ensure valid JSON
          final decoded = jsonDecode(rawPostUrls);
          if (decoded is List) {
            // It's already a valid JSON array string
            postUrl = rawPostUrls;
          } else {
            // It's a JSON string but not an array, make it an array
            postUrl = jsonEncode([decoded]);
          }
          debugPrint('CONTRACT MODEL: Validated JSON string: $postUrl');
        } catch (e) {
          // Not valid JSON, use as-is
          debugPrint('CONTRACT MODEL: Using non-JSON string: $rawPostUrls');
          postUrl = jsonEncode([rawPostUrls]);
        }
      } else {
        // For any other type, try to convert to string
        try {
          postUrl = jsonEncode([rawPostUrls.toString()]);
          debugPrint('CONTRACT MODEL: Converted to JSON array: $postUrl');
        } catch (e) {
          postUrl = rawPostUrls.toString();
          debugPrint('CONTRACT MODEL: Used toString fallback: $postUrl');
        }
      }
    }

    return Contract(
      id: record.id,
      campaign: record.data['campaign'] ?? '',
      brand: record.data['brand'] ?? '',
      influencer: record.data['influencer'] ?? '',
      postType: postTypeList.map((item) => item.toString()).toList(),
      deliveryDate: deliveryDate,
      payout: (record.data['payout'] ?? 0).toDouble(),
      terms: record.data['terms'] ?? '',
      guidelines: record.data['guidelines'] ?? '',
      isSignedByBrand: record.data['is_signed_by_brand'] ?? false,
      isSignedByInfluencer: record.data['is_signed_by_influencer'] ?? false,
      status: record.data['status'] ?? 'pending',
      postUrl: postUrl,
      campaignRecord: record.get<dynamic>("expand.campaign"),
      brandRecord: record.get<dynamic>("expand.brand"),
      influencerRecord: record.get<dynamic>("expand.influencer"),
    );
  }

  Contract copyWith({
    String? id,
    String? campaign,
    String? brand,
    String? influencer,
    List<String>? postType,
    DateTime? deliveryDate,
    double? payout,
    String? terms,
    String? guidelines,
    bool? isSignedByBrand,
    bool? isSignedByInfluencer,
    String? status,
    String? postUrl,
    dynamic campaignRecord,
    dynamic brandRecord,
    dynamic influencerRecord,
  }) {
    return Contract(
      id: id ?? this.id,
      campaign: campaign ?? this.campaign,
      brand: brand ?? this.brand,
      influencer: influencer ?? this.influencer,
      postType: postType ?? this.postType,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      payout: payout ?? this.payout,
      terms: terms ?? this.terms,
      guidelines: guidelines ?? this.guidelines,
      isSignedByBrand: isSignedByBrand ?? this.isSignedByBrand,
      isSignedByInfluencer: isSignedByInfluencer ?? this.isSignedByInfluencer,
      status: status ?? this.status,
      postUrl: postUrl ?? this.postUrl,
      campaignRecord: campaignRecord ?? this.campaignRecord,
      brandRecord: brandRecord ?? this.brandRecord,
      influencerRecord: influencerRecord ?? this.influencerRecord,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign': campaign,
      'brand': brand,
      'influencer': influencer,
      'post_type': postType,
      'delivery_date': deliveryDate.toIso8601String(),
      'payout': payout,
      'terms': terms,
      'guidelines': guidelines,
      'is_signed_by_brand': isSignedByBrand,
      'is_signed_by_influencer': isSignedByInfluencer,
      'status': status,
      'postUrls': postUrl, // Fix to ensure consistent field naming
    };
  }
}
