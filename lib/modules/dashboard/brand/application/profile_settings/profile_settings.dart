import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/dashboard/brand/data/user_repo.dart';
import 'package:meta/meta.dart';
import 'package:pocketbase/pocketbase.dart';

part 'profile_settings_event.dart';
part 'profile_settings_state.dart';

class ProfileSettingsBloc
    extends Bloc<ProfileSettingsEvent, ProfileSettingsState> {
  ProfileSettingsBloc() : super(ProfileSettingsInitial()) {
    on<ProfileSettingsSave>((event, emit) async {
      emit(ProfileSettingsLoading());
      try {
        await UserRepo.updateUserProfile(
          fullName: event.fullName,
          username: event.username,
          industry: event.industry,
          brandName: event.brandName,
        );
        emit(ProfileSettingsSuccess());
      } catch (e) {
        emit(ProfileSettingsFailure(e.toString()));
        throw throw ClientException(originalError: e);
      }
    });
  }
}
