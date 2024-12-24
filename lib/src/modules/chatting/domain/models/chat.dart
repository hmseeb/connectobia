import 'package:connectobia/src/modules/chatting/domain/models/chats.dart';
import 'package:pocketbase/pocketbase.dart';

class Chat {
  final bool acceptedRequest;
  final String brand;
  final String collectionId;
  final String collectionName;
  final String created;
  final bool declinedRequest;
  final Expand? expand;
  final String id;
  final String influencer;
  final bool isRead;
  final String message;
  final String updated;

  Chat({
    required this.acceptedRequest,
    required this.brand,
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.declinedRequest,
    required this.expand,
    required this.id,
    required this.influencer,
    required this.isRead,
    required this.message,
    required this.updated,
  });
  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        acceptedRequest: json["acceptedRequest"],
        brand: json["brand"],
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: json["created"],
        declinedRequest: json["declinedRequest"],
        expand: json["expand"] != null ? Expand.fromJson(json["expand"]) : null,
        id: json["id"],
        influencer: json["influencer"],
        isRead: json["isRead"],
        message: json["message"],
        updated: json["updated"],
      );
  factory Chat.fromRecord(RecordModel record) => Chat.fromJson(record.toJson());

  Map<String, dynamic> toJson() => {
        "acceptedRequest": acceptedRequest,
        "brand": brand,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created,
        "declinedRequest": declinedRequest,
        "expand": expand?.toJson(),
        "id": id,
        "influencer": influencer,
        "isRead": isRead,
        "message": message,
        "updated": updated,
      };
}
