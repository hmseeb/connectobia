import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/storage/pb.dart';
import '../../../../shared/data/repositories/brand_repo.dart';
import '../../../../shared/data/repositories/influencer_repo.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/brand_profile.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../../../shared/domain/models/influencer_profile.dart';
import '../../../../shared/domain/models/review.dart';
import '../../../profile/data/review_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<FetchUser>((event, emit) async {
      try {
        emit(UserLoading());

        final pb = await PocketBaseSingleton.instance;
        final userData = pb.authStore.model;

        if (userData == null) {
          emit(UserError('No authenticated user'));
          return;
        }

        final userId = userData.id;
        final collectionId = userData.collectionId;

        if (collectionId == 'brands') {
          final brand = await BrandRepository.getBrandById(userId);
          emit(UserLoaded(brand));
        } else if (collectionId == 'influencers') {
          final influencer =
              await InfluencerRepository.getInfluencerById(userId);
          emit(UserLoaded(influencer));
        } else {
          emit(UserError('Unknown user type'));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<FetchUserProfile>((event, emit) async {
      try {
        if (state is! UserLoaded) {
          emit(UserError('User data not loaded'));
          return;
        }

        final currentState = state as UserLoaded;
        final profileId = event.profileId;
        final isBrand = event.isBrand;

        if (profileId.isEmpty) {
          emit(UserProfileLoaded(user: currentState.user, profileData: null));
          return;
        }

        // Get profile data
        final pb = await PocketBaseSingleton.instance;
        final profileCollectionName =
            isBrand ? 'brandProfile' : 'influencerProfile';

        final profileRecord =
            await pb.collection(profileCollectionName).getOne(profileId);

        if (isBrand) {
          final profileData = BrandProfile.fromRecord(profileRecord);
          emit(UserProfileLoaded(
              user: currentState.user, profileData: profileData));
        } else {
          final profileData = InfluencerProfile.fromRecord(profileRecord);
          emit(UserProfileLoaded(
              user: currentState.user, profileData: profileData));
        }
      } catch (e) {
        if (state is UserLoaded) {
          // If we have user data but profile fetch failed, return with null profile
          emit(UserProfileLoaded(
              user: (state as UserLoaded).user, profileData: null));
        } else {
          emit(UserError(e.toString()));
        }
      }
    });

    on<UpdateUser>((event, emit) async {
      try {
        if (state is! UserLoaded && state is! UserProfileLoaded) {
          emit(UserError('No user loaded'));
          return;
        }

        emit(UserUpdating());
        dynamic currentUser;

        if (state is UserLoaded) {
          currentUser = (state as UserLoaded).user;
        } else if (state is UserProfileLoaded) {
          currentUser = (state as UserProfileLoaded).user;
        }

        final bool isBrand = currentUser is Brand;
        final userId = currentUser.id;

        // Update user info
        if (isBrand) {
          // Update brand
          final Map<String, dynamic> data = {};

          if (event.brandName != null) data['brandName'] = event.brandName;
          if (event.industry != null) {
            data['industry'] = event.industry;
          }
          if (event.email != null) data['email'] = event.email;

          await BrandRepository.updateBrand(userId, data);

          // Update profile if description exists
          if (event.description != null && event.description!.isNotEmpty) {
            await BrandRepository.updateBrandProfile(
              brand: currentUser,
              description: event.description!,
            );
          }
        } else {
          // Update influencer
          final Map<String, dynamic> data = {};

          if (event.fullName != null) data['fullName'] = event.fullName;
          if (event.username != null) data['username'] = event.username;
          if (event.industry != null) {
            data['industry'] = event.industry;
          }
          if (event.email != null) data['email'] = event.email;
          if (event.socialHandle != null)
            data['socialHandle'] = event.socialHandle;

          await InfluencerRepository.updateInfluencer(userId, data);

          // Update profile if description exists
          if (event.description != null && event.description!.isNotEmpty) {
            await InfluencerRepository.updateInfluencerProfile(
              influencer: currentUser as Influencer,
              description: event.description!,
            );
          }
        }

        add(FetchUser());
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<UpdateUserAvatar>((event, emit) async {
      emit(UserUpdating());
      try {
        final pb = await PocketBaseSingleton.instance;
        final id = pb.authStore.record!.id;
        final collectionName = pb.authStore.record!.collectionName;

        // Create form data for file upload
        final formData = <String, dynamic>{};
        final List<dynamic> files = [];

        if (event.avatar != null) {
          final bytes = await event.avatar!.readAsBytes();
          final fileName = event.avatar!.name;

          // For PocketBase avatar upload, you would use formdata approach
          // This is abstracted away from this method
          // The multipart file setup would depend on your PB configuration
        }

        final updatedRecord = await pb.collection(collectionName).update(
              id,
              body: formData,
              // files: files,
            );

        if (collectionName == 'brands') {
          final brand = Brand.fromRecord(updatedRecord);
          emit(UserLoaded(brand));
        } else {
          final influencer = Influencer.fromRecord(updatedRecord);
          emit(UserLoaded(influencer));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<UpdateUserBanner>((event, emit) async {
      emit(UserUpdating());
      try {
        final pb = await PocketBaseSingleton.instance;
        final id = pb.authStore.record!.id;
        final collectionName = pb.authStore.record!.collectionName;

        // Create form data for file upload
        final formData = <String, dynamic>{};
        final List<dynamic> files = [];

        if (event.banner != null) {
          final bytes = await event.banner!.readAsBytes();
          final fileName = event.banner!.name;

          // For PocketBase banner upload, you would use formdata approach
          // This is abstracted away from this method
          // The multipart file setup would depend on your PB configuration
        }

        final updatedRecord = await pb.collection(collectionName).update(
              id,
              body: formData,
              // files: files,
            );

        if (collectionName == 'brands') {
          final brand = Brand.fromRecord(updatedRecord);
          emit(UserLoaded(brand));
        } else {
          final influencer = Influencer.fromRecord(updatedRecord);
          emit(UserLoaded(influencer));
        }
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<FetchUserReviews>((event, emit) async {
      try {
        // First, make sure we have the user data
        if (state is! UserProfileLoaded) {
          emit(UserError('User profile not loaded'));
          return;
        }

        final currentState = state as UserProfileLoaded;

        // Show loading state
        emit(UserLoading());

        List<Review> reviews = [];
        double averageRating = 0.0;

        // Fetch reviews based on user type
        if (event.isBrand) {
          reviews = await ReviewRepository.getReviewsForBrand(event.userId);
          averageRating =
              await ReviewRepository.getBrandAverageRating(event.userId);
        } else {
          reviews =
              await ReviewRepository.getReviewsForInfluencer(event.userId);
          averageRating =
              await ReviewRepository.getInfluencerAverageRating(event.userId);
        }

        // Sort reviews by date (newest first)
        reviews.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

        emit(UserReviewsLoaded(
          user: currentState.user,
          profileData: currentState.profileData,
          reviews: reviews,
          averageRating: averageRating,
        ));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}
