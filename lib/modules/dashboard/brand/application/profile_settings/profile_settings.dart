import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/dashboard/brand/data/repositories/edit_profile.dart';
import 'package:meta/meta.dart';

import '../../../../../shared/data/repositories/error_repo.dart';

part 'profile_settings_event.dart';
part 'profile_settings_state.dart';

class ProfileSettingsBloc
    extends Bloc<ProfileSettingsEvent, ProfileSettingsState> {
  ProfileSettingsBloc() : super(ProfileSettingsInitial()) {
    on<ProfileSettingsSave>((event, emit) async {
      emit(ProfileSettingsLoading());
      try {
        await EditProfileRepository.updateUserProfile(
          fullName: event.fullName,
          username: event.username,
          industry: event.industry,
          brandName: event.brandName,
        );
        emit(ProfileSettingsSuccess());
      } catch (e) {
        emit(ProfileSettingsFailure(e.toString()));
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });
  }
}
