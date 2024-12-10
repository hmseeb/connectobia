import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../../../../common/domain/repositories/error_repository.dart';
import '../../../auth/data/respository/auth_repo.dart';

part 'influencer_onboard_event.dart';
part 'influencer_onboard_state.dart';

class InfluencerOnboardBloc
    extends Bloc<InfluencerOnboardEvent, InfluencerOnboardState> {
  InfluencerOnboardBloc() : super(InfluencerOnboardInitial()) {
    on<ConnectInstagram>((event, emit) async {
      try {
        emit(ConnectingInstagram());
        await AuthRepo.instagramAuth(collectionName: 'influencer');
        emit(Onboarded());
        await AuthRepo.updateOnboardValue(collectionName: 'influencer');
      } catch (e) {
        emit(ConnectingInstagramFailure(e.toString()));
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });
    on<UpdateOnboardBool>((event, emit) async {
      emit(Onboarded());
      await AuthRepo.updateOnboardValue(collectionName: 'influencer');
    });
  }
}
