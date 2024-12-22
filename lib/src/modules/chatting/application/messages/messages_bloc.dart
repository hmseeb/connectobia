import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/auth/data/respositories/auth_repo.dart';
import 'package:connectobia/src/modules/chatting/data/chats_repository.dart';
import 'package:connectobia/src/modules/chatting/data/messages_repository.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/modules/chatting/domain/models/messages.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:flutter/material.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(MessagesInitial()) {
    on<GetMessagesByUserId>((event, emit) async {
      emit(MessagesLoading());
      MessagesRepository msgsRepo = MessagesRepository();
      try {
        final Messages messages =
            await msgsRepo.getMessagesByUserId(userId: event.userId);

        final pb = await PocketBaseSingleton.instance;
        final selfId = pb.authStore.record!.id;
        emit(MessagesLoaded(messages, selfId));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(MessagesLoadingError(errorRepo.handleError(e)));
      }
    });

    on<SendMessage>((event, emit) async {
      MessagesRepository msgsRepo = MessagesRepository();
      try {
        String senderId = await AuthRepository.getUserId();
        Messages messages = event.messages;
        String chatId = event.chatId;

        Message sendingMessage = Message(
          senderId: senderId,
          recipientId: event.recipientId,
          messageText: event.message,
          messageType: 'text',
          chat: event.chatId,
          isRead: false,
          sent: false,
          created: DateTime.now(),
        );
        final Messages addSendingMessage = messages.addMessage(sendingMessage);
        emit(MessagesLoaded(addSendingMessage, senderId));

        if (chatId.isEmpty) {
          final chatsRepo = ChatsRepository();
          final message = await chatsRepo.createChat(
            recipientId: event.recipientId,
            messageText: event.message,
          );

          Messages sentMessage =
              messages.removeMessage(messages.items.length - 1);
          sentMessage.addMessage(message);
          emit(MessagesLoaded(sentMessage, message.senderId));

          await msgsRepo.updateChatById(
            chatId: message.chat,
            messageId: message.id!,
          );
        } else {
          final message = await msgsRepo.sendMessage(
            recipientId: event.recipientId,
            messageType: 'text',
            messageText: event.message,
            chatId: chatId,
          );

          Messages sentMessage =
              messages.removeMessage(messages.items.length - 1);
          sentMessage.addMessage(message);
          emit(MessagesLoaded(sentMessage, message.senderId));

          await msgsRepo.updateChatById(
            chatId: message.chat,
            messageId: message.id!,
          );
        }
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(MessageNotSent(errorRepo.handleError(e)));
      }
    });
  }
}
