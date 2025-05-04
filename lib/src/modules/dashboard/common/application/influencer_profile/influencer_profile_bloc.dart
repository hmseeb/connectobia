import 'package:bloc/bloc.dart';
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
        // Log detailed information about the attempt
        debugPrint(
            'InfluencerProfileLoad: Trying to load profile with ID: ${event.profileId}');
        debugPrint(
            'InfluencerProfileLoad: Influencer info: ${event.influencer.fullName}, ID: ${event.influencer.id}');

        if (event.profileId.isEmpty) {
          debugPrint(
              '⚠️ Warning: Empty profileId received in InfluencerProfileLoad');
          emit(InfluencerProfileError('Empty profile ID provided'));
          return;
        }

        InfluencerProfile influencerProfile =
            await ProfileRepository.getInfluencerProfile(
                profileId: event.profileId);

        debugPrint('✅ Successfully loaded profile: ${influencerProfile.id}');
        emit(InfluencerProfileLoaded(
          influencer: event.influencer,
          influencerProfile: influencerProfile,
        ));
        debugPrint('Fetched ${event.influencer.fullName} profile');
      } catch (e) {
        debugPrint('❌ Error loading influencer profile: $e');
        // First emit the raw error message
        emit(InfluencerProfileError(e.toString()));
        // Then try to handle it more nicely
        ErrorRepository errorRepo = ErrorRepository();
        final String errorMessage = errorRepo.handleError(e);
        debugPrint('Formatted error: $errorMessage');
        emit(InfluencerProfileError(errorMessage));
      }
    });
  }
}
