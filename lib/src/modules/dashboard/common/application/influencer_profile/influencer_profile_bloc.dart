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

        InfluencerProfile influencerProfile;
        try {
          influencerProfile = await ProfileRepository.getInfluencerProfile(
              profileId: event.profileId);
          debugPrint('✅ Successfully loaded profile: ${influencerProfile.id}');
        } catch (e) {
          // If profile loading fails, create a default profile
          debugPrint('⚠️ Failed to load influencer profile: $e');
          debugPrint(
              'Creating default empty profile for Instagram-less influencer');

          // Create a default empty profile
          influencerProfile = InfluencerProfile(
            id: 'default_${DateTime.now().millisecondsSinceEpoch}',
            collectionId: 'influencerProfile',
            collectionName: 'influencerProfile',
            description:
                'Connect your Instagram account to display your profile information.',
            followers: 0,
            mediaCount: 0,
            engRate: 0,
            created: DateTime.now(),
            updated: DateTime.now(),
          );
        }

        emit(InfluencerProfileLoaded(
          influencer: event.influencer,
          influencerProfile: influencerProfile,
        ));
        debugPrint('Fetched ${event.influencer.fullName} profile');
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(InfluencerProfileError(e.toString()));
        throw errorRepo.handleError(e);
      }
    });
  }
}
