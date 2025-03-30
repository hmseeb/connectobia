import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show MultipartFile;
import 'package:image_picker/image_picker.dart';

import '../../../../services/storage/pb.dart';
import '../../../../shared/data/repositories/brand_repo.dart';
import '../../../../shared/data/repositories/influencer_repo.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/brand_profile.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../../../shared/domain/models/influencer_profile.dart';
import '../../../../shared/domain/models/review.dart';
import '../../../auth/data/repositories/auth_repo.dart';
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

        // Log the collection ID for debugging
        debugPrint('User collection ID: $collectionId');

        // We now handle brand/influencer detection more efficiently in the repositories
        if (collectionId == 'brands') {
          try {
            final brand = await BrandRepository.getBrandById(userId);
            emit(UserLoaded(brand));
          } catch (e) {
            debugPrint('Error loading brand: $e');
            emit(UserError('Failed to load brand: ${e.toString()}'));
          }
        } else if (collectionId == 'influencers') {
          try {
            final influencer =
                await InfluencerRepository.getInfluencerById(userId);
            emit(UserLoaded(influencer));
          } catch (e) {
            debugPrint('Error loading influencer: $e');
            emit(UserError('Failed to load influencer: ${e.toString()}'));
          }
        } else {
          // If we can't determine from authStore, try both collections
          debugPrint(
              'Unknown collection type: $collectionId, attempting detection');
          await _attemptUserTypeDetection(userId, emit);
        }
      } catch (e) {
        debugPrint('Error in FetchUser: $e');
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

    on<FetchUserReviews>((event, emit) async {
      try {
        if (state is! UserLoaded && state is! UserProfileLoaded) {
          emit(UserError('User data not loaded'));
          return;
        }

        dynamic currentUser;
        dynamic profileData;

        if (state is UserLoaded) {
          currentUser = (state as UserLoaded).user;
        } else if (state is UserProfileLoaded) {
          currentUser = (state as UserProfileLoaded).user;
          profileData = (state as UserProfileLoaded).profileData;
        }

        final List<Review> reviews;

        if (event.isBrand) {
          // Get reviews for a brand
          reviews = await ReviewRepository.getReviewsForBrand(event.userId);
        } else {
          // Get reviews for an influencer
          reviews =
              await ReviewRepository.getReviewsForInfluencer(event.userId);
        }

        emit(UserReviewsLoaded(
          user: currentUser,
          profileData: profileData,
          reviews: reviews,
        ));
      } catch (e) {
        debugPrint('Error fetching user reviews: $e');
        emit(UserError('Failed to load reviews: ${e.toString()}'));
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

          // Always update profile description if it's provided (even if empty)
          if (event.description != null) {
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
          if (event.socialHandle != null) {
            data['socialHandle'] = event.socialHandle;
          }

          await InfluencerRepository.updateInfluencer(userId, data);

          // Always update profile description if it's provided (even if empty)
          if (event.description != null) {
            await InfluencerRepository.updateInfluencerProfile(
              influencer: currentUser as Influencer,
              description: event.description!,
            );
          }
        }

        // Fetch the updated user to reflect changes
        final pb = await PocketBaseSingleton.instance;
        final collectionName = isBrand ? 'brands' : 'influencers';
        final updatedRecord =
            await pb.collection(collectionName).getOne(userId);

        if (isBrand) {
          final brand = Brand.fromRecord(updatedRecord);
          emit(UserLoaded(brand));
        } else {
          final influencer = Influencer.fromRecord(updatedRecord);
          emit(UserLoaded(influencer));
        }
      } catch (e) {
        debugPrint('Error updating user: $e');
        emit(UserError(e.toString()));
      }
    });

    on<UpdateUserAvatar>((event, emit) async {
      emit(UserUpdating());
      try {
        final pb = await PocketBaseSingleton.instance;
        final id = pb.authStore.record!.id;
        final collectionName = pb.authStore.record!.collectionName;

        if (event.avatar != null) {
          // Create a multipart file for the avatar upload
          final avatarFile = await event.avatar!.readAsBytes();
          final fileName = 'avatar.${event.avatar!.path.split('.').last}';

          await pb.collection(collectionName).update(
            id,
            files: [
              MultipartFile.fromBytes(
                'avatar',
                avatarFile,
                filename: fileName,
              ),
            ],
          );
        }

        // Fetch the updated record
        final updatedRecord = await pb.collection(collectionName).getOne(id);

        if (collectionName == 'brands') {
          final brand = Brand.fromRecord(updatedRecord);
          emit(UserLoaded(brand));
        } else {
          final influencer = Influencer.fromRecord(updatedRecord);
          emit(UserLoaded(influencer));
        }
      } catch (e) {
        debugPrint('Error updating user avatar: $e');
        emit(UserError(e.toString()));
      }
    });

    on<UpdateUserBanner>((event, emit) async {
      emit(UserUpdating());
      try {
        final pb = await PocketBaseSingleton.instance;
        final id = pb.authStore.record!.id;
        final collectionName = pb.authStore.record!.collectionName;

        if (event.banner != null) {
          // Create a multipart file for the banner upload
          final bannerFile = await event.banner!.readAsBytes();
          final fileName = 'banner.${event.banner!.path.split('.').last}';

          await pb.collection(collectionName).update(
            id,
            files: [
              MultipartFile.fromBytes(
                'banner',
                bannerFile,
                filename: fileName,
              ),
            ],
          );
        }

        // Fetch the updated record
        final updatedRecord = await pb.collection(collectionName).getOne(id);

        if (collectionName == 'brands') {
          final brand = Brand.fromRecord(updatedRecord);
          emit(UserLoaded(brand));
        } else {
          final influencer = Influencer.fromRecord(updatedRecord);
          emit(UserLoaded(influencer));
        }
      } catch (e) {
        debugPrint('Error updating user banner: $e');
        emit(UserError(e.toString()));
      }
    });

    on<RequestEmailChange>((event, emit) async {
      try {
        dynamic currentUser;

        // Check for user state and try to get the current user
        if (state is UserLoaded) {
          currentUser = (state as UserLoaded).user;
          debugPrint('User already loaded: ${currentUser.runtimeType}');
        } else if (state is UserProfileLoaded) {
          currentUser = (state as UserProfileLoaded).user;
          debugPrint('User profile loaded: ${currentUser.runtimeType}');
        } else {
          debugPrint('No user loaded. Attempting to fetch user first...');

          // Try to fetch the user first
          try {
            final user = await AuthRepository.getUser();
            if (user == null) {
              debugPrint('No authenticated user found after fetch attempt');
              emit(UserError('No authenticated user found'));
              return;
            }

            // Successfully fetched user
            debugPrint('Successfully fetched user: ${user.runtimeType}');
            currentUser = user;
            emit(UserLoaded(user));
          } catch (e) {
            debugPrint('Error fetching user: $e');
            emit(UserError('Failed to load user: ${e.toString()}'));
            return;
          }
        }

        // Log the start of email change request
        debugPrint('Starting email change request to: ${event.newEmail}');
        emit(UserUpdating());

        // Request email change through AuthRepository
        await AuthRepository.requestEmailChange(newEmail: event.newEmail);
        debugPrint('Email change request successful');

        // Show success state
        emit(EmailChangeRequested());

        // Re-emit the current user state to stay in a valid state
        emit(UserLoaded(currentUser));
      } catch (e) {
        debugPrint('Error requesting email change: $e');
        emit(UserError(e.toString()));
      }
    });
  }

  // Helper method to detect user type when collection ID doesn't match expected values
  Future<void> _attemptUserTypeDetection(
      String userId, Emitter<UserState> emit) async {
    debugPrint('Attempting to detect user type for ID: $userId');
    try {
      // Try as brand first
      final brand = await BrandRepository.getBrandById(userId);
      debugPrint('Successfully identified user as brand');
      emit(UserLoaded(brand));
      return;
    } catch (brandError) {
      debugPrint('Not a brand user: $brandError');
    }

    try {
      // Try as influencer
      final influencer = await InfluencerRepository.getInfluencerById(userId);
      debugPrint('Successfully identified user as influencer');
      emit(UserLoaded(influencer));
      return;
    } catch (influencerError) {
      debugPrint('Not an influencer user: $influencerError');
    }

    // If we reach here, we couldn't identify the user type
    emit(UserError('Unknown user type. Please check your account settings.'));
  }
}
