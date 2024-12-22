import 'package:connectobia/src/modules/chatting/data/messages_repository.dart';
import 'package:connectobia/src/modules/chatting/domain/models/chats.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatsRepository {
  Future<Message> createChat(
      {required String recipientId, required String messageText}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      String senderId = pb.authStore.record!.id;

      String accountType = CollectionNameSingleton.instance;

      String influencerId =
          accountType == 'influencers' ? senderId : recipientId;
      String brandId = accountType == 'brands' ? senderId : recipientId;

      final body = <String, dynamic>{
        "influencer": influencerId,
        "brand": brandId,
      };

      final chatRecord = await pb.collection('chats').create(body: body);

      String chatId = chatRecord.id;

      MessagesRepository msgsRepo = MessagesRepository();

      final message = await msgsRepo.sendMessage(
        chatId: chatId,
        recipientId: recipientId,
        messageType: 'text',
        messageText: messageText,
      );

      return message;
    } catch (e) {
      throw ClientException;
    }
  }

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
            sort: 'created',
          );

      Chats chats = Chats.fromRecord(resultList);

      return chats;
    } catch (e) {
      debugPrint('$e');
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

      if (chatId.isEmpty) {
        return '';
      }

      return chatId;
    } catch (e) {
      throw ClientException;
    }
  }
}
