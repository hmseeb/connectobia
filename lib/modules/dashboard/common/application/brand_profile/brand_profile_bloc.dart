import 'package:bloc/bloc.dart';
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
      if (state is BrandProfileLoaded) {
        return;
      }
      emit(BrandProfileLoading());
      try {
        final BrandProfile brandProfile =
            await ProfileRepository.getBrandProfile(profileId: event.profileId);
        emit(
            BrandProfileLoaded(brand: event.brand, brandProfile: brandProfile));
        debugPrint('Fetched ${event.brand.brandName} profile');
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });
  }
}
