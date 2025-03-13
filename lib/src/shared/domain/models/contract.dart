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
    };
  }
}
