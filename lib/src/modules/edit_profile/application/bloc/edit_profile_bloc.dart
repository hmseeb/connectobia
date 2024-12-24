// edit_profile_bloc.dart

import 'package:connectobia/src/modules/edit_profile/data/repositories/edit_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(EditProfileInitial());

  Stream<EditProfileState> mapEventToState(EditProfileEvent event) async* {
    if (event is UpdateProfileEvent) {
      yield EditProfileLoading();

      try {
        // Update profile using repository
        await EditProfileRepository.updateUserProfile(
          fullName: event.fullName,
          username: event.username,
          industry: event.industry,
          brandName: event.brandName,
          avatar: event.avatar,
          banner: event.banner,
        );

        yield EditProfileUpdated('Profile updated successfully!');
      } catch (e) {
        yield EditProfileError('Failed to update profile: $e');
      }
    }
  }
}
