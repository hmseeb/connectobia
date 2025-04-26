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
  final String status;

  Contract({
    required this.id,
    required this.campaign,
    required this.brand,
    required this.influencer,
    required this.postType,
    required this.deliveryDate,
    required this.payout,
    required this.terms,
    required this.guidelines,
    required this.isSignedByBrand,
    required this.isSignedByInfluencer,
    required this.status,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'] as String,
      campaign: json['campaign'] as String,
      brand: json['brand'] as String,
      influencer: json['influencer'] as String,
      postType: List<String>.from(json['postType']),
      deliveryDate: json['deliveryDate'].toDate(),
      payout: json['payout'].toDouble(),
      terms: json['terms'] as String,
      guidelines: json['guidelines'] as String? ?? '',
      isSignedByBrand: json['isSignedByBrand'] as bool,
      isSignedByInfluencer: json['isSignedByInfluencer'] as bool,
      status: json['status'] as String,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign': campaign,
      'brand': brand,
      'influencer': influencer,
      'postType': postType,
      'deliveryDate': deliveryDate,
      'payout': payout,
      'terms': terms,
      'guidelines': guidelines,
      'isSignedByBrand': isSignedByBrand,
      'isSignedByInfluencer': isSignedByInfluencer,
      'status': status,
    };
  }
}
