import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/auth/data/repositories/auth_repo.dart';
import 'package:flutter/material.dart';

import '../../../../../shared/data/repositories/error_repo.dart';
import '../../../../../shared/domain/models/influencer.dart';
import '../../../../../shared/domain/models/influencer_profile.dart';
import '../../data/repositories/profile_repo.dart';

part 'influencer_profile_event.dart';
part 'influencer_profile_state.dart';

class InfluencerProfileBloc
    extends Bloc<InfluencerProfileEvent, InfluencerProfileState> {
  InfluencerProfileBloc() : super(InfluencerProfileInitial()) {
    on<InfluencerProfileLoad>((event, emit) async {
      emit(InfluencerProfileLoading());
      try {
        InfluencerProfile influencerProfile =
            await ProfileRepository.getInfluencerProfile(
                profileId: event.profileId);
        final Influencer influencer = await AuthRepository.getUser();

        emit(InfluencerProfileLoaded(
          influencer: event.influencer,
          influencerProfile: influencerProfile,
          hasConnectedSocialMedia: influencer.connectedSocial,
        ));
        debugPrint('Fetched ${event.influencer.fullName} profile');
      } catch (e) {
        emit(InfluencerProfileError(e.toString()));
        ErrorRepository errorRepo = ErrorRepository();
        emit(InfluencerProfileError(errorRepo.handleError(e)));
      }
    });
  }
}
