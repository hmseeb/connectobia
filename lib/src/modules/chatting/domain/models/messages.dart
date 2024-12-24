// To parse this JSON data, do
//
//     final messages = messagesFromJson(jsonString);

import 'dart:convert';

import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:pocketbase/pocketbase.dart';

Messages messagesFromJson(String str) => Messages.fromJson(json.decode(str));

String messagesToJson(Messages data) => json.encode(data.toJson());

class Messages {
  final List<Message> items;
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;

  Messages({
    required this.items,
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
  });

  factory Messages.fromJson(Map<String, dynamic> json) => Messages(
        items:
            List<Message>.from(json["items"].map((x) => Message.fromJson(x))),
        page: json["page"],
        perPage: json["perPage"],
        totalItems: json["totalItems"],
        totalPages: json["totalPages"],
      );

  factory Messages.fromRecord(ResultList<RecordModel> record) =>
      Messages.fromJson(record.toJson());

  // Method to add a message to the items list
  Messages addMessage(Message newMessage) {
    items.insert(0, newMessage);
    return Messages(
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      totalItems: totalItems + 1,
      items: items,
    );
  }

  Messages removeMessage(int index) {
    items.remove(items[index]);
    return Messages(
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      totalItems: totalItems - 1,
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "page": page,
        "perPage": perPage,
        "totalItems": totalItems,
        "totalPages": totalPages,
      };
}
