import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/auth/domain/model/influencer.dart';
import 'package:connectobia/modules/dashboard/application/data/influencer_repo.dart';
import 'package:meta/meta.dart';

part 'influencer_profile_event.dart';
part 'influencer_profile_state.dart';

class InfluencerProfileBloc
    extends Bloc<InfluencerProfileEvent, InfluencerProfileState> {
  InfluencerProfileBloc() : super(InfluencerProfileInitial()) {
    on<InfluencerProfileLoad>((event, emit) async {
      emit(InfluencerProfileLoading());
      try {
        final Influencer influencer =
            await InfluencerRepo.getInfluencerProfile(event.id);
        emit(InfluencerProfileLoaded(influencer));
      } catch (e) {
        emit(InfluencerProfileError(e.toString()));
      }
    });
  }
}
