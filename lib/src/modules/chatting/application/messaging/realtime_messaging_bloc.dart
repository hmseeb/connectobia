import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/auth/data/repositories/auth_repo.dart';
import 'package:connectobia/src/modules/chatting/data/chats_repository.dart';
import 'package:connectobia/src/modules/chatting/data/messaging_repo.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/modules/chatting/domain/models/messages.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/data/repositories/notification_repository.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

        // Check if the user is authenticated
        if (!pb.authStore.isValid || pb.authStore.record == null) {
          debugPrint('Cannot subscribe to messages: User not authenticated');
          return; // Exit early without throwing an error
        }

        final userId = pb.authStore.record!.id;
        debugPrint('Subscribing to messages for user: $userId');

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
        debugPrint('Successfully subscribed to messages');
      } catch (e) {
        debugPrint('Error subscribing to messages: $e');
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

        // Create a notification for the message
        try {
          await NotificationRepository.createMessageNotification(
            userId: userId,
            senderName: brand.brandName,
            message: event.message.messageText,
            chatId: event.message.chat,
          );
        } catch (e) {
          debugPrint('Error creating message notification: $e');
          // Don't fail the message handling if notification fails
        }

        emit(MessageNotificationReceived(
          avatar: brand.avatar,
          name: brand.brandName,
          userId: brand.id,
          message: event.message.messageText,
          chatId: event.message.chat,
          collectionId: brand.collectionId,
        ));

        HapticFeedback.vibrate();

        if (prevState is MessagesLoaded) {
          final Messages messages = prevState.messages;
          final updatedMessages = messages.addMessage(event.message);
          emit(MessagesLoaded(selfId: userId, messages: updatedMessages));
        }
      } else {
        final influencer = Influencer.fromRecord(record);

        // Create a notification for the message
        try {
          await NotificationRepository.createMessageNotification(
            userId: userId,
            senderName: influencer.fullName,
            message: event.message.messageText,
            chatId: event.message.chat,
          );
        } catch (e) {
          debugPrint('Error creating message notification: $e');
          // Don't fail the message handling if notification fails
        }

        emit(MessageNotificationReceived(
          avatar: influencer.avatar,
          name: influencer.fullName,
          userId: influencer.id,
          message: event.message.messageText,
          chatId: event.message.chat,
          collectionId: influencer.collectionId,
        ));

        HapticFeedback.vibrate();

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

    on<SendMedia>((event, emit) async {
      try {
        MessagesRepository msgsRepo = MessagesRepository();
        String senderId = await AuthRepository.getUserId();
        Messages messages = event.messages;
        String chatId = event.chatId;
        String messageId = DateTime.now().millisecondsSinceEpoch.toString();
        Message sendingMessage = Message(
          senderId: senderId,
          recipientId: event.recipientId,
          messageText: ' Sending image...',
          id: messageId,
          messageType: 'text',
          chat: event.chatId,
          sent: false,
          created: DateTime.now().toIso8601String(),
        );

        final Messages addSendingMessage = messages.addMessage(sendingMessage);
        emit(MessagesLoaded(messages: addSendingMessage, selfId: senderId));

        final message = await msgsRepo.sendMedia(
          senderId: senderId,
          recipientId: event.recipientId,
          chatId: chatId,
          path: event.path,
          fileName: event.fileName,
        );

        Messages sentMessage = messages.removeMessageWithId(messageId);
        sentMessage.addMessage(message);

        HapticFeedback.lightImpact();
        emit(MessagesLoaded(
          messages: sentMessage,
          selfId: senderId,
        ));

        await msgsRepo.updateChatById(
          chatId: message.chat,
          messageId: message.id!,
          isRead: false,
        );
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(MessageNotSent(errorRepo.handleError(e)));
      }
    });

    on<SendTextMessage>((event, emit) async {
      MessagesRepository msgsRepo = MessagesRepository();
      try {
        debugPrint(
            "📨 SendTextMessage event received in bloc with message: ${event.message}");
        debugPrint(
            "📨 chatId empty? ${event.chatId.isEmpty}, recipientId: ${event.recipientId}");

        String senderId = await AuthRepository.getUserId();
        debugPrint("📨 Sender ID: $senderId");

        Messages messages = event.messages;
        String chatId = event.chatId;
        // generate a random id for the message
        String messageId = DateTime.now().millisecondsSinceEpoch.toString();
        Message sendingMessage = Message(
          senderId: senderId,
          recipientId: event.recipientId,
          messageText: event.message,
          id: messageId,
          messageType: 'text',
          chat: event.chatId,
          sent: false,
          created: DateTime.now().toIso8601String(),
        );
        final Messages addSendingMessage = messages.addMessage(sendingMessage);
        debugPrint("📨 Emitting MessagesLoaded with temporary message");
        emit(MessagesLoaded(messages: addSendingMessage, selfId: senderId));

        if (chatId.isEmpty) {
          debugPrint("📨 Creating NEW chat because chatId is empty");
          final chatsRepo = ChatsRepository();
          debugPrint(
              "📨 Calling createChat with recipientId: ${event.recipientId}, message: ${event.message}");

          try {
            final message = await chatsRepo.createChat(
              recipientId: event.recipientId,
              messageText: event.message,
            );
            debugPrint("📨 Chat created successfully with id: ${message.chat}");

            Messages sentMessage = messages.removeMessageWithId(messageId);
            sentMessage.addMessage(message);

            // Create a notification for the recipient
            try {
              // Get sender name based on account type
              String accountType = CollectionNameSingleton.instance;
              String senderName = '';

              final currentUser = await AuthRepository.getUser();
              if (accountType == 'brands') {
                senderName = (currentUser as Brand).brandName;
              } else {
                senderName = (currentUser as Influencer).fullName;
              }

              await NotificationRepository.createMessageNotification(
                userId: event.recipientId,
                senderName: senderName,
                message: event.message,
                chatId: message.chat,
              );
              debugPrint(
                  'Created message notification for recipient: ${event.recipientId}');
            } catch (e) {
              debugPrint(
                  'Error creating message notification for recipient: $e');
              // Don't fail the message handling if notification fails
            }

            HapticFeedback.lightImpact();
            debugPrint("📨 Emitting final MessagesLoaded with real message");
            emit(MessagesLoaded(messages: sentMessage, selfId: senderId));

            await msgsRepo.updateChatById(
              chatId: message.chat,
              messageId: message.id!,
              isRead: false,
            );
          } catch (e) {
            debugPrint("📨 ERROR in createChat: $e");
            rethrow; // Re-throw to be caught by outer catch
          }
        } else {
          final message = await msgsRepo.sendTextMessage(
            recipientId: event.recipientId,
            messageType: 'text',
            messageText: event.message,
            chatId: chatId,
          );

          Messages sentMessage = messages.removeMessageWithId(messageId);
          sentMessage.addMessage(message);

          // Create a notification for the recipient
          try {
            // Get sender name based on account type
            String accountType = CollectionNameSingleton.instance;
            String senderName = '';

            final currentUser = await AuthRepository.getUser();
            if (accountType == 'brands') {
              senderName = (currentUser as Brand).brandName;
            } else {
              senderName = (currentUser as Influencer).fullName;
            }

            await NotificationRepository.createMessageNotification(
              userId: event.recipientId,
              senderName: senderName,
              message: event.message,
              chatId: message.chat,
            );
            debugPrint(
                'Created message notification for recipient: ${event.recipientId}');
          } catch (e) {
            debugPrint('Error creating message notification for recipient: $e');
            // Don't fail the message handling if notification fails
          }

          HapticFeedback.lightImpact();
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
