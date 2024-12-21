import 'package:connectobia/src/modules/chatting/domain/models/messages.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:pocketbase/pocketbase.dart';

class MessagesRepository {
  Future<RecordModel> sendMessage(
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
}
