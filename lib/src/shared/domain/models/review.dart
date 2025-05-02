import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Review {
  final String id;
  final String collectionId;
  final String collectionName;
  final String? fromBrand;
  final String? toInfluencer;
  final String? fromInfluencer;
  final String? toBrand;
  final String campaign;
  final int rating;
  final String comment;
  final String role;
  final DateTime submittedAt;
  final DateTime created;
  final DateTime updated;

  // Optional expanded records
  final dynamic campaignRecord;
  final dynamic brandRecord;
  final dynamic influencerRecord;

  Review({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    this.fromBrand,
    this.toInfluencer,
    this.fromInfluencer,
    this.toBrand,
    required this.campaign,
    required this.rating,
    required this.comment,
    required this.role,
    required this.submittedAt,
    required this.created,
    required this.updated,
    this.campaignRecord,
    this.brandRecord,
    this.influencerRecord,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      collectionId: json['collectionId'],
      collectionName: json['collectionName'],
      fromBrand: json['from_brand'],
      toInfluencer: json['to_influencer'],
      fromInfluencer: json['from_influencer'],
      toBrand: json['to_brand'],
      campaign: json['campaign'],
      rating: int.tryParse(json['rating'].toString()) ?? 5,
      comment: json['comment'] ?? '',
      role: json['role'] ?? '',
      submittedAt: DateTime.parse(json['submitted_at']),
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
      campaignRecord: json['expand']?['campaign'],
      brandRecord: json['expand']?['from_brand'] ?? json['expand']?['to_brand'],
      influencerRecord: json['expand']?['from_influencer'] ??
          json['expand']?['to_influencer'],
    );
  }

  factory Review.fromRawJson(String str) => Review.fromJson(json.decode(str));

  factory Review.fromRecord(RecordModel record) {
    return Review(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      fromBrand: record.data['from_brand'],
      toInfluencer: record.data['to_influencer'],
      fromInfluencer: record.data['from_influencer'],
      toBrand: record.data['to_brand'],
      campaign: record.data['campaign'],
      rating: int.tryParse(record.data['rating'].toString()) ?? 5,
      comment: record.data['comment'] ?? '',
      role: record.data['role'] ?? '',
      submittedAt: DateTime.parse(record.data['submitted_at']),
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
      campaignRecord: record.expand['campaign'],
      brandRecord: record.expand['from_brand'] ?? record.expand['to_brand'],
      influencerRecord:
          record.expand['from_influencer'] ?? record.expand['to_influencer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'from_brand': fromBrand,
      'to_influencer': toInfluencer,
      'from_influencer': fromInfluencer,
      'to_brand': toBrand,
      'campaign': campaign,
      'rating': rating,
      'comment': comment,
      'role': role,
      'submitted_at': submittedAt.toIso8601String(),
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  String toRawJson() => json.encode(toJson());
}
