import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

part 'influencer_onboard_event.dart';
part 'influencer_onboard_state.dart';

class InfluencerOnboardBloc
    extends Bloc<InfluencerOnboardEvent, InfluencerOnboardState> {
  InfluencerOnboardBloc() : super(InfluencerOnboardInitial()) {
    on<ConnectInstagram>((event, emit) async {
      try {
        assert(false, 'Not implemented');
        emit(ConnectingInstagram());
        // await AuthRepo.loginWithInstagram();
        emit(ConnectedInstagram());
      } catch (e) {
        emit(ConnectingInstagramFailure(e.toString()));
        rethrow;
      }
    });
  }
}
