import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/chatting/data/chats_repository.dart';
import 'package:connectobia/src/modules/chatting/domain/models/chats.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:meta/meta.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc() : super(ChatsInitial()) {
    on<GetChats>((event, emit) async {
      try {
        emit(ChatsLoading());
        ChatsRepository chatsRepo = ChatsRepository();
        final Chats chats = await chatsRepo.getChats();
        emit(ChatsLoaded(chats));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(ChatsLoadingError(errorRepo.handleError(e)));
      }
    });
  }
}
