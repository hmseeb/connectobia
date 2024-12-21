import 'package:connectobia/src/modules/chatting/domain/models/chats.dart';
import 'package:connectobia/src/modules/chatting/domain/models/messages.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:pocketbase/pocketbase.dart';

class MessageRepository {
  Future<RecordModel> createChat(
      {required String senderId,
      required String recipientId,
      required String messageText}) async {
    try {
      String accountType = CollectionNameSingleton.instance;

      String influencerId =
          accountType == 'influencers' ? senderId : recipientId;
      String brandId = accountType == 'brands' ? senderId : recipientId;

      final pb = await PocketBaseSingleton.instance;

      final body = <String, dynamic>{
        "influencer": influencerId,
        "brand": brandId,
      };

      final record = await pb.collection('chats').create(body: body);
      String chatId = record.id;

      await sendMessage(
        chatId: chatId,
        senderId: senderId,
        recipientId: recipientId,
        messageType: 'text',
        messageText: messageText,
      );
      return record;
    } catch (e) {
      throw ClientException;
    }
  }

  Future<RecordModel> sendMessage(
      {required String chatId,
      required String senderId,
      required String recipientId,
      required String messageType,
      required String messageText}) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      final body = <String, dynamic>{
        "senderId": senderId,
        "recipientId": recipientId,
        "messageText": messageText,
        "messageType": 'text',
        "chat": chatId,
        "isRead": false
      };

      final record = await pb.collection('messages').create(body: body);
      return record;
    } catch (e) {
      throw ClientException;
    }
  }

  Future<Messages> getMessages({required String chatId}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final resultList = await pb.collection('messages').getList(
            page: 1,
            perPage: 20,
            filter: 'chat == $chatId',
            sort: 'created',
          );

      Messages messages = Messages.fromRecord(resultList);
      return messages;
    } catch (e) {
      throw ClientException;
    }
  }

  Future<Chats> getChats({required String userId}) async {
    try {
      String accountType = CollectionNameSingleton.instance;

      // Remove the 's' from the account type
      accountType = accountType.replaceAll('s', '');

      final pb = await PocketBaseSingleton.instance;
      final resultList = await pb.collection('chats').getList(
            page: 1,
            perPage: 20,
            filter: '$accountType == $userId',
            expand: 'influencer,brand,message',
            sort: 'created',
          );

      Chats chats = Chats.fromRecord(resultList);

      return chats;
    } catch (e) {
      throw ClientException;
    }
  }
}
