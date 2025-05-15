import 'package:connectobia/src/modules/chatting/data/messaging_repo.dart';
import 'package:connectobia/src/modules/chatting/domain/models/chats.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

/// [ChatsRepository] is a class that handles all the chat related operations.
/// It is responsible for creating a chat, getting all the chats, and getting the chat ID.
///
/// The class uses the [PocketBaseSingleton] to get the instance of the PocketBase SDK.
class ChatsRepository {
  /// [createChat] is a method that creates a chat between two users.
  /// It takes the recipient ID and the message text as parameters.
  Future<Message> createChat(
      {required String recipientId, required String messageText}) async {
    try {
      debugPrint("🔄 createChat called with recipientId: $recipientId");
      final pb = await PocketBaseSingleton.instance;
      String senderId = pb.authStore.record!.id;
      debugPrint("🔄 Sender ID: $senderId");

      String accountType = CollectionNameSingleton.instance;
      debugPrint("🔄 Account Type: $accountType");

      String influencerId =
          accountType == 'influencers' ? senderId : recipientId;
      String brandId = accountType == 'brands' ? senderId : recipientId;
      debugPrint("🔄 Influencer ID: $influencerId, Brand ID: $brandId");

      final body = <String, dynamic>{
        "influencer": influencerId,
        "brand": brandId,
      };

      debugPrint("🔄 Creating chat record with body: $body");
      final chatRecord = await pb.collection('chats').create(body: body);
      debugPrint("🔄 Chat record created with ID: ${chatRecord.id}");

      MessagesRepository msgsRepo = MessagesRepository();
      debugPrint("🔄 Sending first text message in new chat");
      final messageRecord = await msgsRepo.sendTextMessage(
        chatId: chatRecord.id,
        recipientId: recipientId,
        messageType: 'text',
        messageText: messageText,
      );
      debugPrint("🔄 Message record created with ID: ${messageRecord.id}");

      await msgsRepo.updateChatById(
          chatId: chatRecord.id, isRead: false, messageId: messageRecord.id);
      debugPrint("🔄 Chat updated with message ID");

      return messageRecord;
    } catch (e) {
      debugPrint("🔄 ERROR in createChat: $e");
      throw ClientException;
    }
  }

  Future<String> getChatID(String recipientId) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final String selfId = pb.authStore.record!.id;
      String accountType = CollectionNameSingleton.instance;
      String influencerId = accountType == 'influencers' ? selfId : recipientId;
      String brandId = accountType == 'brands' ? selfId : recipientId;
      final resultList = await pb.collection('chats').getFirstListItem(
          'influencer = "$influencerId" && brand = "$brandId"');
      String chatId = resultList.id;
      if (chatId.isEmpty) {
        return '';
      }
      return chatId;
    } catch (e) {
      throw ClientException;
    }
  }

  Future<String> getChatIdByUserId(String userId) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final String selfId = pb.authStore.record!.id;

      String accountType = CollectionNameSingleton.instance;

      String influencerId = accountType == 'influencers' ? selfId : userId;
      String brandId = accountType == 'brands' ? selfId : userId;

      final resultList = await pb.collection('chats').getFirstListItem(
          'influencer = "$influencerId" && brand = "$brandId"');
      String chatId = resultList.id;

      return chatId;
    } catch (e) {
      throw ClientException;
    }
  }

  /// [getChats] is a method that gets all the chats of the current user.
  /// It returns a [Chats] object.
  /// The [Chats] object contains a list of [Chat] objects.
  /// Each [Chat] object contains the chat details.
  Future<Chats> getChats() async {
    try {
      final pb = await PocketBaseSingleton.instance;

      String accountType = CollectionNameSingleton.instance;

      // Remove the 's' from the account type
      accountType = accountType.replaceAll('s', '');

      final String userId = pb.authStore.record!.id;

      final resultList = await pb.collection('chats').getList(
            page: 1,
            perPage: 20,
            filter: '$accountType = "$userId"',
            expand: 'influencer,brand,message',
            sort: '-updated',
          );

      Chats chats = Chats.fromRecord(resultList);

      return chats;
    } catch (e) {
      debugPrint('$e');
      throw ClientException;
    }
  }

  Future<Message> sendMedia({
    required List<XFile> images,
    required String senderId,
    required String recipientId,
    required String chatId,
  }) async {
    try {
      List<http.MultipartFile> multipartFiles = [];
      for (var img in images) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          img.path,
          filename: img.name, // You can change this to any file name
        );
        multipartFiles.add(multipartFile);
      }
      final pb = await PocketBaseSingleton.instance;

      // example create body
      final body = <String, dynamic>{
        "senderId": senderId,
        "recipientId": recipientId,
        "messageType": "image",
        "chat": chatId,
      };
      final record = await pb
          .collection('messages')
          .create(body: body, files: multipartFiles);

      Message message = Message.fromRecord(record);

      return message;
    } catch (e) {
      debugPrint('$e');
      throw ClientException;
    }
  }
}
