// To parse this JSON data, do
//
//     final chats = chatsFromJson(jsonString);

import 'dart:convert';

import 'package:connectobia/src/modules/chatting/domain/models/chat.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:pocketbase/pocketbase.dart';

Chats chatsFromJson(String str) => Chats.fromJson(json.decode(str));

String chatsToJson(Chats data) => json.encode(data.toJson());

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

  factory Chats.fromRecord(ResultList<RecordModel> record) =>
      Chats.fromJson(record.toJson());
  Chats addChat(Chat chat) {
    items.add(chat);
    items.sort((a, b) => b.updated.compareTo(a.updated));

    return Chats(
      items: items,
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      totalItems: totalItems + 1,
    );
  }

  Chats filterChats(String filter) {
    //
    List<Chat> filteredItems = items.where((chat) {
      return chat.expand!.message.messageText.contains(filter) ||
          chat.expand!.influencer.fullName.contains(filter) ||
          chat.expand!.brand.brandName.contains(filter);
    }).toList();
    return Chats(
      page: page,
      perPage: perPage,
      totalPages: totalPages,
      totalItems: filteredItems.length,
      items: filteredItems,
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

  // Method to add a message to the items list
  Chats updateChat(
      {required String influencer,
      required String brand,
      required Chat updatedChat}) {
    int index = items.indexWhere((element) =>
        element.influencer == influencer && element.brand == brand);
    if (index != -1) {
      items[index] = updatedChat; // Update the chat if it exists
      items.sort((a, b) => b.updated.compareTo(a.updated));
    } else {
      items.add(updatedChat); // Add new chat if it does not exist
      items.sort((a, b) => b.updated.compareTo(a.updated));
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
  final Influencer influencer;
  final Brand brand;
  final Message message;

  Expand({
    required this.influencer,
    required this.message,
    required this.brand,
  });

  factory Expand.fromJson(Map<String, dynamic> json) => Expand(
        influencer: Influencer.fromJson(json["influencer"]),
        message: Message.fromJson(json["message"]),
        brand: Brand.fromJson(json["brand"]),
      );

  Map<String, dynamic> toJson() => {
        "influencer": influencer.toJson(),
        "message": message.toJson(),
      };
}
