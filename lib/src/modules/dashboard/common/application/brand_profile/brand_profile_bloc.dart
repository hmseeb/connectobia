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
        // Log detailed information about the attempt
        debugPrint(
            'BrandProfileLoad: Trying to load profile with ID: ${event.profileId}');
        debugPrint(
            'BrandProfileLoad: Brand info: ${event.brand.brandName}, ID: ${event.brand.id}');

        if (event.profileId.isEmpty) {
          debugPrint(
              '⚠️ Warning: Empty profileId received in BrandProfileLoad');
          emit(BrandProfileError('Empty profile ID provided'));
          return;
        }

        final BrandProfile brandProfile =
            await ProfileRepository.getBrandProfile(profileId: event.profileId);

        // Check what type of user is currently logged in
        bool isInfluencerVerified = false;
        try {
          final user = await AuthRepository.getUser();
          debugPrint('Current user type: ${user.runtimeType}');

          // If the user is an influencer, check if they're verified
          if (user is Influencer) {
            isInfluencerVerified = user.connectedSocial;
          }
        } catch (e) {
          debugPrint('Error getting current user type: $e');
          // Default to false if there's an error
          isInfluencerVerified = false;
        }

        debugPrint('✅ Successfully loaded profile: ${brandProfile.id}');
        emit(BrandProfileLoaded(
          brand: event.brand,
          brandProfile: brandProfile,
          isInfluencerVerified: isInfluencerVerified,
        ));
        debugPrint('Fetched ${event.brand.brandName} profile');
      } catch (e) {
        debugPrint('❌ Error loading brand profile: $e');
        ErrorRepository errorRepo = ErrorRepository();
        emit(BrandProfileError(errorRepo.handleError(e)));
      }
    });
  }
}
