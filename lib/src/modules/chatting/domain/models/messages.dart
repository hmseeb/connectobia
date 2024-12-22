import 'dart:convert';

import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:pocketbase/pocketbase.dart';

class Messages {
  final int page;
  final int perPage;
  final int totalPages;
  final int totalItems;
  final List<Message> items;

  Messages({
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
  });

  factory Messages.fromRecord(ResultList<RecordModel> record) =>
      Messages.fromJson(record.toJson());

  factory Messages.fromRawJson(String str) =>
      Messages.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Messages.fromJson(Map<String, dynamic> json) => Messages(
        page: json["page"],
        perPage: json["perPage"],
        totalPages: json["totalPages"],
        totalItems: json["totalItems"],
        items:
            List<Message>.from(json["items"].map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "perPage": perPage,
        "totalPages": totalPages,
        "totalItems": totalItems,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };

  // Method to add a message to the items list
  Messages addMessage(Message newMessage) {
    items.add(newMessage);
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
}
