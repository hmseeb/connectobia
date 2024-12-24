import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/auth/data/repositories/auth_repo.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:flutter/material.dart';

import '../../../../../shared/data/repositories/error_repo.dart';
import '../../../../../shared/domain/models/brand.dart';
import '../../../../../shared/domain/models/brand_profile.dart';
import '../../data/repositories/profile_repo.dart';

part 'brand_profile_event.dart';
part 'brand_profile_state.dart';

class BrandProfileBloc extends Bloc<BrandProfileEvent, BrandProfileState> {
  BrandProfileBloc() : super(BrandProfileInitial()) {
    on<LoadBrandProfile>((event, emit) async {
      emit(BrandProfileLoading());
      try {
        final BrandProfile brandProfile =
            await ProfileRepository.getBrandProfile(profileId: event.profileId);

        Influencer influencer = await AuthRepository.getUser();

        emit(BrandProfileLoaded(
          brand: event.brand,
          brandProfile: brandProfile,
          isInfluencerVerified: influencer.connectedSocial,
        ));
        debugPrint('Fetched ${event.brand.brandName} profile');
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(BrandProfileError(errorRepo.handleError(e)));
      }
    });
  }
}
