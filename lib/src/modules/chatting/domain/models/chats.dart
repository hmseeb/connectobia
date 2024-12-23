import 'dart:convert';

import 'package:connectobia/src/modules/chatting/domain/models/chat.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:pocketbase/pocketbase.dart';

class Chats {
  final List<Chat> items;
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

  factory Chats.fromJson(Map<String, dynamic> json) => Chats(
        items: List<Chat>.from(json["items"].map((x) => Chat.fromJson(x))),
        page: json["page"],
        perPage: json["perPage"],
        totalItems: json["totalItems"],
        totalPages: json["totalPages"],
      );

  factory Chats.fromRawJson(String str) => Chats.fromJson(json.decode(str));

  factory Chats.fromRecord(ResultList<RecordModel> record) =>
      Chats.fromJson(record.toJson());

  Chats addChat(Chat chat) {
    items.add(chat);
    return Chats(
      items: items,
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      totalItems: totalItems + 1,
    );
  }

  Chats removeMessage(int index) {
    items.remove(items[index]);
    return Chats(
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

  String toRawJson() => json.encode(toJson());

  // Method to add a message to the items list
  Chats updateChat(
      {required String influencer,
      required String brand,
      required Chat updatedChat}) {
    int index = items.indexWhere((element) =>
        element.influencer == influencer && element.brand == brand);
    if (index != -1) {
      items[index] = updatedChat; // Update the chat if it exists
    } else {
      items.add(updatedChat); // Add new chat if it does not exist
    }
    return Chats(
      items: items,
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      totalItems: totalItems,
    );
  }
}

class Expand {
  final Brand? brand;
  final Influencer? influencer;
  final Message? message;

  Expand({
    required this.brand,
    required this.influencer,
    required this.message,
  });

  factory Expand.fromJson(Map<String, dynamic> json) => Expand(
        brand: Brand.fromJson(json["brand"]),
        influencer: Influencer.fromJson(json["influencer"]),
        message: Message.fromJson(json["message"]),
      );

  factory Expand.fromRawJson(String str) => Expand.fromJson(json.decode(str));

  Map<String, dynamic> toJson() => {
        "brand": brand!.toJson(),
        "influencer": influencer!.toJson(),
        "message": message!.toJson(),
      };

  String toRawJson() => json.encode(toJson());
}
