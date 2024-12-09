import 'package:bloc/bloc.dart';
import 'package:connectobia/common/models/influencer_profile.dart';
import 'package:connectobia/modules/auth/domain/model/influencer.dart';
import 'package:connectobia/modules/dashboard/application/data/influencer_repo.dart';
import 'package:meta/meta.dart';

part 'influencer_profile_event.dart';
part 'influencer_profile_state.dart';

class InfluencerProfileBloc
    extends Bloc<InfluencerProfileEvent, InfluencerProfileState> {
  InfluencerProfileBloc() : super(InfluencerProfileInitial()) {
    on<InfluencerProfileLoad>((event, emit) async {
      // TODO: Avoid loading the same profile twice
      emit(InfluencerProfileLoading());
      try {
        final InfluencerProfile influencerProfile =
            await InfluencerRepo.getInfluencerProfile(event.profileId);
        emit(InfluencerProfileLoaded(
            influencer: event.influencer,
            influencerProfile: influencerProfile));
      } catch (e) {
        emit(InfluencerProfileError(e.toString()));
        throw Exception(e);
      }
    });
  }
}
