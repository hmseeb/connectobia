import 'package:connectobia/modules/chatting/domain/models/chats.dart';
import 'package:connectobia/modules/chatting/domain/models/messages.dart';
import 'package:connectobia/services/storage/pb.dart';
import 'package:pocketbase/pocketbase.dart';

class MessageRepository {
  Future<RecordModel> createChat(
      {required String influencerId, required String brandId}) async {
    final pb = await PocketBaseSingleton.instance;

    final body = <String, dynamic>{
      "influencer": influencerId,
      "brand": brandId,
    };

    final record = await pb.collection('chats').create(body: body);
    return record;
  }

  Future<RecordModel> addNewMessage(
      {required String chatId,
      required String senderId,
      required String recipientId,
      required String messageType,
      required String messageText}) async {
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
  }

  Future<Messages> getMessages({required String chatId}) async {
    final pb = await PocketBaseSingleton.instance;

    try {
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
    final pb = await PocketBaseSingleton.instance;

    try {
      final resultList = await pb.collection('chats').getList(
            page: 1,
            perPage: 20,
            filter: 'influencer == $userId OR brand == $userId',
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
