// To parse this JSON data, do
//
//     final userList = userListFromJson(jsonString);

import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

UserList userListFromJson(String str) => UserList.fromJson(json.decode(str));

String userListToJson(UserList data) => json.encode(data.toJson());

class Item {
  final String id;
  final String collectionId;
  final String collectionName;
  final String username;
  final bool verified;
  final bool emailVisibility;
  final String? email;
  final DateTime created;
  final DateTime updated;
  final String fullName;
  final String avatar;
  final String brandName;
  final String accountType;
  final String industry;
  final String banner;

  Item({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.username,
    required this.verified,
    required this.emailVisibility,
    this.email,
    required this.created,
    required this.updated,
    required this.fullName,
    required this.avatar,
    required this.brandName,
    required this.accountType,
    required this.industry,
    required this.banner,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        username: json["username"],
        verified: json["verified"],
        emailVisibility: json["emailVisibility"],
        email: json["email"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
        fullName: json["full_name"],
        avatar: json["avatar"],
        brandName: json["brand_name"],
        accountType: json["account_type"],
        industry: json["industry"],
        banner: json["banner"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "username": username,
        "verified": verified,
        "emailVisibility": emailVisibility,
        "email": email,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
        "full_name": fullName,
        "avatar": avatar,
        "brand_name": brandName,
        "account_type": accountType,
        "industry": industry,
        "banner": banner,
      };
}

class UserList {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<Item> items;

  UserList({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
        page: json["page"],
        perPage: json["perPage"],
        totalPages: json["totalPages"],
        totalItems: json["totalItems"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  factory UserList.fromRecord(ResultList<RecordModel> record) =>
      UserList.fromJson(record.toJson());

  Map<String, dynamic> toJson() => {
        "page": page,
        "perPage": perPage,
        "totalPages": totalPages,
        "totalItems": totalItems,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}
