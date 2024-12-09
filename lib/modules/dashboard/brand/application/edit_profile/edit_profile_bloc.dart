import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/edit_profile.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(EditProfileInitial()) {
    on<EditProfileSave>((event, emit) async {
      await EditProfileRepo.updateInfluencerProfile(
          title: event.title, description: event.description);
    });
  }
}
