import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Message {
  final String audio;
  final String chat;
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final String file;
  final String id;
  final String image;
  final bool isRead;
  final String messageText;
  final String messageType;
  final String recipientId;
  final String senderId;
  final DateTime updated;

  Message({
    required this.audio,
    required this.chat,
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.file,
    required this.id,
    required this.image,
    required this.isRead,
    required this.messageText,
    required this.messageType,
    required this.recipientId,
    required this.senderId,
    required this.updated,
  });
  factory Message.fromRecord(RecordModel record) =>
      Message.fromJson(record.toJson());
  factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        audio: json["audio"],
        chat: json["chat"],
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: DateTime.parse(json["created"]),
        file: json["file"],
        id: json["id"],
        image: json["image"],
        isRead: json["isRead"],
        messageText: json["messageText"],
        messageType: json["messageType"],
        recipientId: json["recipientId"],
        senderId: json["senderId"],
        updated: DateTime.parse(json["updated"]),
      );

  Map<String, dynamic> toJson() => {
        "audio": audio,
        "chat": chat,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created.toIso8601String(),
        "file": file,
        "id": id,
        "image": image,
        "isRead": isRead,
        "messageText": messageText,
        "messageType": messageType,
        "recipientId": recipientId,
        "senderId": senderId,
        "updated": updated.toIso8601String(),
      };
}
