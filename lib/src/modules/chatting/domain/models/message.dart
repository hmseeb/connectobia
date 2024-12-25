import 'package:connectobia/src/modules/chatting/domain/models/chat.dart';
import 'package:pocketbase/pocketbase.dart';

class Expand {
  final Chat chat;

  Expand({
    required this.chat,
  });

  factory Expand.fromJson(Map<String, dynamic> json) => Expand(
        chat: Chat.fromJson(json["chat"]),
      );

  Map<String, dynamic> toJson() => {
        "chat": chat.toJson(),
      };
}

class Message {
  final String? audio;
  final String chat;
  final String? collectionId;
  final String? collectionName;
  final String created;
  final Expand? expand;
  final bool? sent;
  final String? file;
  final String? id;
  final List<String>? image;
  final String messageText;
  final String messageType;
  final String recipientId;
  final String senderId;
  final String? updated;

  Message({
    this.audio,
    required this.chat,
    this.collectionId,
    this.collectionName,
    required this.created,
    this.expand,
    this.file,
    this.sent,
    this.id,
    this.image,
    required this.messageText,
    required this.messageType,
    required this.recipientId,
    required this.senderId,
    this.updated,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        audio: json["audio"],
        chat: json["chat"],
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: json["created"],
        expand: json["expand"] != null ? Expand.fromJson(json["expand"]) : null,
        file: json["file"],
        id: json["id"],
        image: List<String>.from(json["image"].map((x) => x)),
        messageText: json["messageText"],
        messageType: json["messageType"],
        recipientId: json["recipientId"],
        senderId: json["senderId"],
        updated: json["updated"],
      );

  factory Message.fromRecord(RecordModel record) =>
      Message.fromJson(record.toJson());

  Map<String, dynamic> toJson() => {
        "audio": audio,
        "chat": chat,
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created,
        "expand": expand?.toJson(),
        "file": file,
        "id": id,
        "image": List<dynamic>.from(image!.map((x) => x)),
        "messageText": messageText,
        "messageType": messageType,
        "recipientId": recipientId,
        "senderId": senderId,
        "updated": updated,
      };
}
