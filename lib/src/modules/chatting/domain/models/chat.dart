import 'dart:convert';

import 'package:connectobia/src/modules/chatting/domain/models/chats.dart';
import 'package:pocketbase/pocketbase.dart';

class Chat {
  final String collectionId;
  final String collectionName;
  final String id;
  final Expand expand;
  final String influencer;
  final String brand;
  final String message;
  final DateTime created;
  final DateTime updated;

  Chat({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.influencer,
    required this.brand,
    required this.expand,
    required this.message,
    required this.created,
    required this.updated,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        id: json["id"],
        influencer: json["influencer"],
        expand: Expand.fromJson(json["expand"]),
        brand: json["brand"],
        message: json["message"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
      );

  factory Chat.fromRawJson(String str) => Chat.fromJson(json.decode(str));

  factory Chat.fromRecord(RecordModel record) => Chat.fromJson(record.toJson());

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "id": id,
        "influencer": influencer,
        "brand": brand,
        "expand": expand.toJson(),
        "message": message,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
      };
  String toRawJson() => json.encode(toJson());
}
