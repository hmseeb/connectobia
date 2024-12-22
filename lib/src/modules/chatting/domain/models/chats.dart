import 'dart:convert';

import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:pocketbase/pocketbase.dart';

class Chats {
  final List<Item> items;
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;

  Chats({
    required this.items,
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
  });

  factory Chats.fromRecord(ResultList<RecordModel> record) =>
      Chats.fromJson(record.toJson());

  factory Chats.fromRawJson(String str) => Chats.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Chats.fromJson(Map<String, dynamic> json) => Chats(
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        page: json["page"],
        perPage: json["perPage"],
        totalItems: json["totalItems"],
        totalPages: json["totalPages"],
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "page": page,
        "perPage": perPage,
        "totalItems": totalItems,
        "totalPages": totalPages,
      };
}

class Item {
  final bool acceptedRequest;
  final String brand;
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final bool declinedRequest;
  final Expand expand;
  final String id;
  final String influencer;
  final String message;
  final DateTime updated;

  Item({
    required this.acceptedRequest,
    required this.brand,
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.declinedRequest,
    required this.expand,
    required this.id,
    required this.influencer,
    required this.message,
    required this.updated,
  });

  factory Item.fromRawJson(String str) => Item.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        acceptedRequest: json["acceptedRequest"],
        brand: json["brand"],
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: DateTime.parse(json["created"]),
        declinedRequest: json["declinedRequest"],
        expand: Expand.fromJson(json["expand"]),
        id: json["id"],
        influencer: json["influencer"],
        message: json["message"],
        updated: DateTime.parse(json["updated"]),
      );

  Map<String, dynamic> toJson() => {
        "acceptedRequest": acceptedRequest,
        "brand": brand,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created.toIso8601String(),
        "declinedRequest": declinedRequest,
        "expand": expand.toJson(),
        "id": id,
        "influencer": influencer,
        "message": message,
        "updated": updated.toIso8601String(),
      };
}

class Expand {
  final Brand brand;
  final Influencer influencer;
  final Message message;

  Expand({
    required this.brand,
    required this.influencer,
    required this.message,
  });

  factory Expand.fromRawJson(String str) => Expand.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Expand.fromJson(Map<String, dynamic> json) => Expand(
        brand: Brand.fromJson(json["brand"]),
        influencer: Influencer.fromJson(json["influencer"]),
        message: Message.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "brand": brand.toJson(),
        "influencer": influencer.toJson(),
        "message": message.toJson(),
      };
}
