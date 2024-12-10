import 'package:bloc/bloc.dart';
import 'package:connectobia/common/models/brand_profile.dart';
import 'package:connectobia/modules/auth/domain/model/brand.dart';
import 'package:connectobia/modules/dashboard/common/data/influencer_repo.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

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
            await SearchRepo.getBrandProfile(profileId: event.profileId);
        emit(
            BrandProfileLoaded(brand: event.brand, brandProfile: brandProfile));
        debugPrint('Fetched ${event.brand.brandName} profile');
      } catch (e) {
        throw throw ClientException(originalError: e);
      }
    });
  }
}
