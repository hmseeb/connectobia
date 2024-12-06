import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:flutter/cupertino.dart';

part 'influencer_onboard_event.dart';
part 'influencer_onboard_state.dart';

class InfluencerOnboardBloc
    extends Bloc<InfluencerOnboardEvent, InfluencerOnboardState> {
  InfluencerOnboardBloc() : super(InfluencerOnboardInitial()) {
    on<ConnectInstagram>((event, emit) async {
      try {
        emit(ConnectingInstagram());
        await AuthRepo.authWithInstagram();
        emit(ConnectedInstagram());
      } catch (e) {
        emit(ConnectingInstagramFailure(e.toString()));
        rethrow;
      }
    });
  }
}
