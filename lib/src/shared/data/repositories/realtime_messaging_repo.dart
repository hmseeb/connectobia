import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/modules/chatting/domain/models/messages.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

/// [MessagesRepository] is a class that handles all the message related operations.
/// It is responsible for sending a message, getting all the messages by chat ID, and getting all the messages by user ID.
///
/// The class uses the [PocketBaseSingleton] to get the instance of the PocketBase SDK.
class MessagesRepository {
  Future<Messages> getMessagesByChatId({required String chatId}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final resultList = await pb.collection('messages').getList(
            page: 1,
            perPage: 20,
            filter: 'chat == $chatId',
            sort: '-updated',
          );

      Messages messages = Messages.fromRecord(resultList);
      return messages;
    } catch (e) {
      debugPrint('$e');
      throw ClientException();
    }
  }

  Future<Messages> getMessagesByUserId({required String userId}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final selfId = pb.authStore.record!.id;
      String filter =
          'senderId = "$selfId" && recipientId = "$userId" || senderId = "$userId" && recipientId = "$selfId"';
      final resultList = await pb.collection('messages').getList(
            page: 1,
            perPage: 20,
            filter: filter,
            sort: '-created',
          );

      Messages messages = Messages.fromRecord(resultList);
      return messages;
    } catch (e) {
      debugPrint('$e');
      throw ClientException();
    }
  }

  Future<RecordModel> getUserById(String userId) async {
    final pb = await PocketBaseSingleton.instance;

    String accountType = CollectionNameSingleton.instance;
    String otherUserAccountType =
        accountType == 'brands' ? 'influencers' : 'brands';

    final record = await pb.collection(otherUserAccountType).getOne(userId);

    return record;
  }

  /// [sendMessage] is a method that sends a message to a user.
  /// It takes the chat ID, recipient ID, message type, and message text as parameters.
  /// It returns a [Message] object.
  /// The [Message] object contains the message details.
  Future<Message> sendMessage(
      {required String chatId,
      required String recipientId,
      required String messageType,
      required String messageText}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      String senderId = pb.authStore.record!.id;

      final body = <String, dynamic>{
        "senderId": senderId,
        "recipientId": recipientId,
        "messageText": messageText,
        "messageType": 'text',
        "chat": chatId,
        "isRead": false,
      };

      final record = await pb.collection('messages').create(body: body);
      return Message.fromRecord(record);
    } catch (e) {
      debugPrint('$e');
      throw ClientException();
    }
  }

  Future<void> updateChatById(
      {required String chatId, required String messageId}) async {
    final pb = await PocketBaseSingleton.instance;
    final body = <String, dynamic>{
      "message": messageId,
    };

    await pb.collection('chats').update(chatId, body: body);
  }
}
