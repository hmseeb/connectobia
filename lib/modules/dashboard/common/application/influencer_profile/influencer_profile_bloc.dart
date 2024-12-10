import 'package:bloc/bloc.dart';
import 'package:connectobia/common/models/influencer_profile.dart';
import 'package:connectobia/modules/auth/domain/model/influencer.dart';
import 'package:connectobia/modules/dashboard/common/data/influencer_repo.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

part 'influencer_profile_event.dart';
part 'influencer_profile_state.dart';

class InfluencerProfileBloc
    extends Bloc<InfluencerProfileEvent, InfluencerProfileState> {
  InfluencerProfileBloc() : super(InfluencerProfileInitial()) {
    on<InfluencerProfileLoad>((event, emit) async {
      if (state is InfluencerProfileLoaded) {
        return;
      }
      emit(InfluencerProfileLoading());
      try {
        InfluencerProfile influencerProfile =
            await SearchRepo.getInfluencerProfile(profileId: event.profileId);
        emit(InfluencerProfileLoaded(
            influencer: event.influencer,
            influencerProfile: influencerProfile));
        debugPrint('Fetched ${event.influencer.fullName} profile');
      } catch (e) {
        emit(InfluencerProfileError(e.toString()));
        throw throw ClientException(originalError: e);
      }
    });
  }
}
