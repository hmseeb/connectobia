import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../../shared/data/repositories/error_repo.dart';
import '../../../auth/data/repositories/auth_repo.dart';

part 'influencer_onboard_event.dart';
part 'influencer_onboard_state.dart';

class InfluencerOnboardBloc
    extends Bloc<InfluencerOnboardEvent, InfluencerOnboardState> {
  InfluencerOnboardBloc() : super(InfluencerOnboardInitial()) {
    on<ConnectInstagram>((event, emit) async {
      try {
        emit(ConnectingInstagram());
        await AuthRepository.instagramAuth(collectionName: 'influencers');
        emit(Onboarded());
        await AuthRepository.updateOnboardValue(collectionName: 'influencers');
      } catch (e) {
        emit(ConnectingInstagramFailure(e.toString()));
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });
    on<UpdateOnboardBool>((event, emit) async {
      emit(Onboarded());
      await AuthRepository.updateOnboardValue(collectionName: 'influencers');
    });
  }
}
