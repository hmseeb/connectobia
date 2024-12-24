import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/auth/data/repositories/auth_repo.dart';
import 'package:connectobia/src/modules/chatting/data/chats_repository.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/modules/chatting/domain/models/messages.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/data/repositories/realtime_messaging_repo.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

part 'realtime_messaging_event.dart';
part 'realtime_messaging_state.dart';

class RealtimeMessagingBloc
    extends Bloc<RealtimeMessagingEvent, RealtimeMessagingState> {
  RealtimeMessagingBloc() : super(RealtimeMessagingInitial()) {
    on<UnsubscribeMessages>((event, emit) async {
      try {
        final pb = await PocketBaseSingleton.instance;
        pb.collection('messages').unsubscribe();
        debugPrint('Unsubscribed from messages');
      } catch (e) {
        emit(RealtimeMessagingError(e.toString()));
      }
    });

    on<SubscribeMessages>((event, emit) async {
      try {
        final pb = await PocketBaseSingleton.instance;
        final userId = pb.authStore.record!.id;

        // Subscribe to changes in the messages collection
        pb.collection('messages').subscribe(
          "*",
          (e) {
            if (e.action == 'create') {
              final Message message = Message.fromRecord(e.record!);
              add(AddNewMessage(message));
            }
          },
          filter: "recipientId = '$userId'",
          expand: 'chat',
        ).asStream();
        debugPrint('Subscribed to messages');
      } catch (e) {
        emit(RealtimeMessagingError(e.toString()));
      }
    });
    on<AddNewMessage>((event, emit) async {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.record!.id;

      MessagesRepository messagesRepository = MessagesRepository();
      final RecordModel record =
          await messagesRepository.getUserById(event.message.senderId);

      String accountType = CollectionNameSingleton.instance;
      String otherUserAccountType =
          accountType == 'brands' ? 'influencers' : 'brands';

      RealtimeMessagingState prevState = state;

      if (otherUserAccountType == 'brands') {
        final brand = Brand.fromRecord(record);

        emit(MessageNotificationReceived(
          avatar: brand.avatar,
          name: brand.brandName,
          userId: brand.id,
          message: event.message.messageText,
          chatId: event.message.chat,
          collectionId: brand.collectionId,
        ));

        if (prevState is MessagesLoaded) {
          final Messages messages = prevState.messages;
          final updatedMessages = messages.addMessage(event.message);
          emit(MessagesLoaded(selfId: userId, messages: updatedMessages));
        }
      } else {
        final influencer = Influencer.fromRecord(record);
        emit(MessageNotificationReceived(
          avatar: influencer.avatar,
          name: influencer.fullName,
          userId: influencer.id,
          message: event.message.messageText,
          chatId: event.message.chat,
          collectionId: influencer.collectionId,
        ));
        if (prevState is MessagesLoaded) {
          final Messages messages = prevState.messages;
          final updatedMessages = messages.addMessage(event.message);
          emit(MessagesLoaded(selfId: userId, messages: updatedMessages));
        }
      }
    });

    on<GetMessagesByUserId>((event, emit) async {
      emit(MessagesLoading());
      MessagesRepository msgsRepo = MessagesRepository();
      try {
        final Messages messages =
            await msgsRepo.getMessagesByUserId(userId: event.userId);
        if (messages.items.isNotEmpty) {
          final recipientId = messages.items[0].recipientId;
          String currentUserId = await AuthRepository.getUserId();
          final chatId = messages.items[0].chat;
          if (currentUserId == recipientId) {
            await msgsRepo.updateChatById(
              chatId: chatId,
              isRead: true,
            );
          }
        }

        final pb = await PocketBaseSingleton.instance;
        final selfId = pb.authStore.record!.id;
        emit(MessagesLoaded(messages: messages, selfId: selfId));
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
          sent: false,
          created: DateTime.now().toIso8601String(),
        );
        final Messages addSendingMessage = messages.addMessage(sendingMessage);
        emit(MessagesLoaded(messages: addSendingMessage, selfId: senderId));

        if (chatId.isEmpty) {
          final chatsRepo = ChatsRepository();
          final message = await chatsRepo.createChat(
            recipientId: event.recipientId,
            messageText: event.message,
          );

          Messages sentMessage = messages.removeMessage(0);
          sentMessage.addMessage(message);
          emit(MessagesLoaded(messages: sentMessage, selfId: senderId));

          await msgsRepo.updateChatById(
              chatId: message.chat, messageId: message.id!, isRead: false);
        } else {
          final message = await msgsRepo.sendMessage(
            recipientId: event.recipientId,
            messageType: 'text',
            messageText: event.message,
            chatId: chatId,
          );

          Messages sentMessage = messages.removeMessage(0);
          sentMessage.addMessage(message);
          emit(MessagesLoaded(
            messages: sentMessage,
            selfId: senderId,
          ));

          await msgsRepo.updateChatById(
            chatId: message.chat,
            messageId: message.id!,
            isRead: false,
          );
        }
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(MessageNotSent(errorRepo.handleError(e)));
      }
    });
  }
}
