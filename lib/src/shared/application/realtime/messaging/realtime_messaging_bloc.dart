import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:flutter/material.dart';

part 'realtime_messaging_event.dart';
part 'realtime_messaging_state.dart';

class RealtimeMessagingBloc
    extends Bloc<RealtimeMessagingEvent, RealtimeMessagingState> {
  RealtimeMessagingBloc() : super(RealtimeMessagingInitial()) {
    on<SubscribeMessages>((event, emit) async {
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
    });
    on<AddNewMessage>((event, emit) async {
      debugPrint(event.message.messageText);
    });
  }
}
