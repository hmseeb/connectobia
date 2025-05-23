import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

import 'brand.dart';

class Brands {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<Brand> items;

  Brands({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });
  factory Brands.fromJson(Map<String, dynamic> json) => Brands(
        page: json["page"],
        perPage: json["perPage"],
        totalPages: json["totalPages"],
        totalItems: json["totalItems"],
        items: List<Brand>.from(json["items"].map((x) => Brand.fromJson(x))),
      );

  factory Brands.fromRawJson(String str) => Brands.fromJson(json.decode(str));

  factory Brands.fromRecord(ResultList<RecordModel> record) =>
      Brands.fromJson(record.toJson());

  Brands copyWith({
    int? page,
    int? perPage,
    int? totalPages,
    int? totalItems,
    List<Brand>? items,
  }) =>
      Brands(
        page: page ?? this.page,
        perPage: perPage ?? this.perPage,
        totalPages: totalPages ?? this.totalPages,
        totalItems: totalItems ?? this.totalItems,
        items: items ?? this.items,
      );

  Brands filterBrands(String filter) {
    //
    List<Brand> filteredItems = items.where((brand) {
      return brand.brandName.contains(filter) ||
          brand.industry.contains(filter);
    }).toList();
    return Brands(
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      totalItems: filteredItems.length,
      items: filteredItems,
    );
  }

  /// Filter brands list to only show items with IDs in the provided list
  Brands filterByIds(List<String> ids) {
    if (ids.isEmpty) {
      return copyWith(totalItems: 0, items: []);
    }

    List<Brand> filteredItems = items.where((brand) {
      return ids.contains(brand.id);
    }).toList();

    return copyWith(
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
