import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

class Message {
  final String? audio;
  final String chat;
  final String? collectionId;
  final String? collectionName;
  final DateTime created;
  final String? file;
  final String? id;
  final bool? sent;
  final String? image;
  final bool isRead;
  final String messageText;
  final String? messageType;
  final String recipientId;
  final String senderId;
  final DateTime? updated;

  Message({
    this.audio,
    required this.chat,
    this.collectionId,
    this.collectionName,
    required this.created,
    this.file,
    this.sent,
    this.id,
    this.image,
    required this.isRead,
    required this.messageText,
    this.messageType,
    required this.recipientId,
    required this.senderId,
    this.updated,
  });
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
  factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

  factory Message.fromRecord(RecordModel record) =>
      Message.fromJson(record.toJson());

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
        "updated": updated!.toIso8601String(),
      };

  String toRawJson() => json.encode(toJson());
}
