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
  Chats? chats;
  ChatsBloc() : super(ChatsInitial()) {
    on<GetChats>((event, emit) async {
      try {
        emit(ChatsLoading());
        ChatsRepository chatsRepo = ChatsRepository();
        chats = await chatsRepo.getChats();
        debugPrint('Loaded chats');
        emit(ChatsLoaded(chats!));
        add(SubscribeChats(prevChats: chats!));
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
            if (e.action == 'update') {
              final Chat chat = Chat.fromRecord(e.record!);
              add(UpdatedChat(newChat: chat, prevChats: chats!));
            }
          },
          filter: filter,
          expand: 'message,brand,influencer',
        );
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        debugPrint(errorRepo.handleError(e));
      }
    });

    on<FilterChats>((event, emit) {
      if (state is ChatsLoaded) {
        final filteredChats = chats!.filterChats(event.filter);
        emit(ChatsLoaded(filteredChats));
      }
    });

    on<UpdatedChat>((event, emit) {
      chats = chats!.updateChat(
        influencer: event.newChat.influencer,
        brand: event.newChat.brand,
        updatedChat: event.newChat,
      );
      emit(ChatsLoaded(chats!));
    });

    on<CreatedChat>((event, emit) async {
      try {
        chats = chats!.addChat(event.newChat);
        emit(ChatsLoaded(chats!));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(ChatsLoadingError(errorRepo.handleError(e)));
      }
    });
    on<UnsubscribeChats>((event, emit) async {
      try {
        final pb = await PocketBaseSingleton.instance;
        await pb.collection('chats').unsubscribe();
        debugPrint('Unsubscribed to chats');
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(ChatsLoadingError(errorRepo.handleError(e)));
      }
    });
  }
}
