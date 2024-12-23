import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/chatting/data/chats_repository.dart';
import 'package:connectobia/src/modules/chatting/domain/models/chat.dart';
import 'package:connectobia/src/modules/chatting/domain/models/chats.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:flutter/material.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc() : super(ChatsInitial()) {
    on<GetChats>((event, emit) async {
      try {
        emit(ChatsLoading());
        ChatsRepository chatsRepo = ChatsRepository();
        final Chats chats = await chatsRepo.getChats();
        debugPrint('Loaded chats');
        emit(ChatsLoaded(chats));
        add(SubscribeChats(prevChats: chats));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(ChatsLoadingError(errorRepo.handleError(e)));
      }
    });

    on<SubscribeChats>((event, emit) async {
      try {
        final pb = await PocketBaseSingleton.instance;

        String userId = pb.authStore.record!.id;

        // Subscribe to changes in the messages collection
        String filter = 'brand = "$userId" || influencer = "$userId"';
        await pb.collection('chats').subscribe(
          "*",
          (e) {
            final Chat chat = Chat.fromRecord(e.record!);
            add(UpdateChat(newChat: chat, prevChats: event.prevChats));
          },
          filter: filter,
          expand: 'message,brand,influencer',
        );
        debugPrint('Subscribed to chats');
      } catch (e) {
        emit(ChatsLoadingError(e.toString()));
      }
    });
    on<UpdateChat>((event, emit) {
      final Chats updatedChats = event.prevChats.updateChat(
        influencer: event.newChat.influencer,
        brand: event.newChat.brand,
        updatedChat: event.newChat,
      );
      emit(ChatsLoaded(updatedChats));
    });
    on<UnsubscribeChats>((event, emit) async {
      try {
        final pb = await PocketBaseSingleton.instance;

        pb.collection('chats').unsubscribe();
        debugPrint('Unsubscribed to chats');
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(ChatsLoadingError(errorRepo.handleError(e)));
      }
    });
  }
}
