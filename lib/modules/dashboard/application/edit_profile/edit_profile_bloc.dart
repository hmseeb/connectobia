import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/dashboard/data/user_repo.dart';
import 'package:meta/meta.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(EditProfileInitial()) {
    on<EditProfileSave>((event, emit) async {
      emit(EditProfileLoading());
      try {
        await UserRepo.updateUserProfile(
          firstName: event.firstName,
          lastName: event.lastName,
          username: event.username,
          industry: event.industry,
          brandName: event.brandName,
        );
        emit(EditProfileSuccess());
      } catch (e) {
        emit(EditProfileFailure(e.toString()));
      }
    });
  }
}
