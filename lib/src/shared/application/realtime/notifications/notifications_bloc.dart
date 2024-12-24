import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:flutter/material.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(NotificationsInitial()) {
    on<MessageNotificationReceived>((event, emit) {
      debugPrint(event.message.messageText);
      emit(MessageReceived(
        message: event.message,
        avatar: event.avatar,
        name: event.name,
        userId: event.userId,
        collectionId: event.collectionId,
        chatId: event.chatId,
        hasConnectedInstagram: event.hasConnectedInstagram,
      ));
    });
  }
}
