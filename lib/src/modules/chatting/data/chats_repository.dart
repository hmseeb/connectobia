import 'package:connectobia/src/modules/chatting/data/messages_repository.dart';
import 'package:connectobia/src/modules/chatting/domain/models/chats.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:pocketbase/pocketbase.dart';

class ChatsRepository {
  Future<RecordModel> createChat(
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

      final record = await pb.collection('chats').create(body: body);
      String chatId = record.id;

      MessagesRepository msgsRepo = MessagesRepository();

      await msgsRepo.sendMessage(
        chatId: chatId,
        recipientId: recipientId,
        messageType: 'text',
        messageText: messageText,
      );
      return record;
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
