import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/dashboard/brand/data/edit_profile.dart';
import 'package:meta/meta.dart';

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
