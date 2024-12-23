import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/realtime_messaging_repo.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

part 'realtime_messaging_event.dart';
part 'realtime_messaging_state.dart';

class RealtimeMessagingBloc
    extends Bloc<RealtimeMessagingEvent, RealtimeMessagingState> {
  RealtimeMessagingBloc() : super(RealtimeMessagingInitial()) {
    on<SubscribeMessages>((event, emit) async {
      try {
        final pb = await PocketBaseSingleton.instance;
        final userId = pb.authStore.record!.id;

        // Subscribe to changes in the messages collection
        pb.collection('messages').subscribe("*", (e) {
          if (e.action == 'create') {
            final Message message = Message.fromRecord(e.record!);
            add(AddNewMessage(message));
          }
        }, filter: "recipientId = '$userId'").asStream();
        debugPrint('Subscribed to messages');
      } catch (e) {
        emit(RealtimeMessagingError(e.toString()));
      }
    });
    on<AddNewMessage>((event, emit) async {
      debugPrint('Getting user name and avatar');
      RealtimeMessagingRepo realtimeMessagingRepo = RealtimeMessagingRepo();
      final RecordModel record =
          await realtimeMessagingRepo.getUserById(event.message.senderId);

      String accountType = CollectionNameSingleton.instance;
      String otherUserAccountType =
          accountType == 'brands' ? 'influencers' : 'brands';
      if (otherUserAccountType == 'brands') {
        final brand = Brand.fromRecord(record);
        emit(RealtimeMessageReceived(
          message: event.message,
          avatar: brand.avatar,
          name: brand.brandName,
          collectionId: record.collectionId,
          userId: brand.id,
          chatId: event.message.chat,
          hasConnectedInstagram: false,
        ));
      } else {
        final influencer = Influencer.fromRecord(record);
        emit(RealtimeMessageReceived(
          message: event.message,
          avatar: influencer.avatar,
          name: influencer.fullName,
          collectionId: record.collectionId,
          userId: influencer.id,
          chatId: event.message.chat,
          hasConnectedInstagram: influencer.connectedSocial,
        ));
      }
    });
  }
}
