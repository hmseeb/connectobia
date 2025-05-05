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
          debugPrint('Cannot update: no user loaded in state');

          // Try to recover by fetching user data
          debugPrint('Attempting to recover by fetching user data directly');
          try {
            final user = await AuthRepository.getUser();
            if (user != null) {
              debugPrint(
                  'Successfully fetched user data, continuing with update');
              emit(UserLoaded(user));

              // Process with newly loaded user
              await _processUserUpdate(user, event, emit);
              return;
            } else {
              debugPrint('Failed to fetch user data for recovery');
              emit(UserError('No user loaded and recovery failed'));
              return;
            }
          } catch (e) {
            debugPrint('Error during recovery attempt: $e');
            emit(UserError('No user loaded: ${e.toString()}'));
            return;
          }
        }

        emit(UserUpdating());
        dynamic currentUser;

        // More robust approach to extract the current user from state
        if (state is UserLoaded) {
          currentUser = (state as UserLoaded).user;
          debugPrint('Extracted user from UserLoaded state');
        } else if (state is UserProfileLoaded) {
          currentUser = (state as UserProfileLoaded).user;
          debugPrint('Extracted user from UserProfileLoaded state');
        } else if (state is UserUpdating) {
          // We might have lost user data during a previous update
          // Try to recover from the PocketBase auth store
          debugPrint('State is UserUpdating, attempting to recover user data');
          try {
            currentUser = await AuthRepository.getUser();
            if (currentUser != null) {
              debugPrint('Successfully retrieved user from AuthRepository');
            }
          } catch (e) {
            debugPrint('Failed to recover user from AuthRepository: $e');
          }
        }

        // Add strict null checks to avoid "id was called on null" error
        if (currentUser == null) {
          debugPrint(
              'Cannot update: currentUser is null after state extraction');

          // Try to recover by fetching user data
          debugPrint('Attempting to recover by fetching user data directly');
          try {
            final pb = await PocketBaseSingleton.instance;
            if (!pb.authStore.isValid || pb.authStore.record == null) {
              throw Exception('Auth store is invalid or has no record');
            }

            final userId = pb.authStore.record!.id;
            final collectionName = pb.authStore.record!.collectionName;

            if (userId.isEmpty || collectionName.isEmpty) {
              throw Exception('Invalid user ID or collection name');
            }

            debugPrint(
                'Attempting direct fetch from $collectionName with ID $userId');
            final userRecord =
                await pb.collection(collectionName).getOne(userId);

            if (collectionName == 'brands') {
              currentUser = Brand.fromRecord(userRecord);
            } else {
              currentUser = Influencer.fromRecord(userRecord);
            }

            if (currentUser != null) {
              debugPrint('Successfully fetched user data for recovery');
              emit(UserLoaded(currentUser));
              await _processUserUpdate(currentUser, event, emit);
              return;
            } else {
              emit(UserError('User object is null and recovery failed'));
              return;
            }
          } catch (e) {
            debugPrint('Error during recovery attempt: $e');
            emit(UserError('User object is null: ${e.toString()}'));
            return;
          }
        }

        await _processUserUpdate(currentUser, event, emit);
      } catch (e) {
        debugPrint('Error updating user: $e');
        emit(UserError(e.toString()));
      }
    });

    on<UpdateUserAvatar>((event, emit) async {
      emit(UserUpdating());
      try {
        final pb = await PocketBaseSingleton.instance;

        // Check if authStore is valid and has a record
        if (!pb.authStore.isValid || pb.authStore.record == null) {
          debugPrint(
              'Cannot update avatar: authStore is invalid or has no record');

          // Try to recover by refreshing auth
          try {
            debugPrint('Attempting to recover authentication state');
            final user = await AuthRepository.getUser();
            if (user != null) {
              debugPrint('Successfully recovered user, retrying avatar update');

              // Try again with the valid authentication
              // We need to get a fresh pb instance to ensure it has the updated auth
              final freshPb = await PocketBaseSingleton.instance;

              if (!freshPb.authStore.isValid ||
                  freshPb.authStore.record == null) {
                debugPrint('Still invalid auth after recovery attempt');
                emit(UserError('Authentication information missing'));
                return;
              }

              // Continue with the updated auth
              final id = freshPb.authStore.record!.id;
              final collectionName = freshPb.authStore.record!.collectionName;

              await _processAvatarUpdate(id, collectionName, event, emit);
              return;
            } else {
              debugPrint('Recovery failed, user is null');
              emit(UserError('Authentication information missing'));
              return;
            }
          } catch (e) {
            debugPrint('Error during auth recovery attempt: $e');
            emit(UserError(
                'Authentication information missing: ${e.toString()}'));
            return;
          }
        }

        final id = pb.authStore.record!.id;
        final collectionName = pb.authStore.record!.collectionName;

        // Defensive checks for ID and collection
        if (id.isEmpty) {
          debugPrint('Cannot update avatar: user ID is missing');
          emit(UserError('User ID is missing'));
          return;
        }

        if (collectionName.isEmpty) {
          debugPrint('Cannot update avatar: collection name is missing');
          emit(UserError('User collection information is missing'));
          return;
        }

        await _processAvatarUpdate(id, collectionName, event, emit);
      } catch (e) {
        debugPrint('Error updating user avatar: $e');
        emit(UserError(e.toString()));
      }
    });

    on<UpdateUserBanner>((event, emit) async {
      emit(UserUpdating());
      try {
        final pb = await PocketBaseSingleton.instance;

        // Check if authStore is valid and has a record
        if (!pb.authStore.isValid || pb.authStore.record == null) {
          debugPrint(
              'Cannot update banner: authStore is invalid or has no record');

          // Try to recover by refreshing auth
          try {
            debugPrint('Attempting to recover authentication state');
            final user = await AuthRepository.getUser();
            if (user != null) {
              debugPrint('Successfully recovered user, retrying banner update');

              // Try again with the valid authentication
              // We need to get a fresh pb instance to ensure it has the updated auth
              final freshPb = await PocketBaseSingleton.instance;

              if (!freshPb.authStore.isValid ||
                  freshPb.authStore.record == null) {
                debugPrint('Still invalid auth after recovery attempt');
                emit(UserError('Authentication information missing'));
                return;
              }

              // Continue with the updated auth
              final id = freshPb.authStore.record!.id;
              final collectionName = freshPb.authStore.record!.collectionName;

              await _processBannerUpdate(id, collectionName, event, emit);
              return;
            } else {
              debugPrint('Recovery failed, user is null');
              emit(UserError('Authentication information missing'));
              return;
            }
          } catch (e) {
            debugPrint('Error during auth recovery attempt: $e');
            emit(UserError(
                'Authentication information missing: ${e.toString()}'));
            return;
          }
        }

        final id = pb.authStore.record!.id;
        final collectionName = pb.authStore.record!.collectionName;

        // Defensive checks for ID and collection
        if (id.isEmpty) {
          debugPrint('Cannot update banner: user ID is missing');
          emit(UserError('User ID is missing'));
          return;
        }

        if (collectionName.isEmpty) {
          debugPrint('Cannot update banner: collection name is missing');
          emit(UserError('User collection information is missing'));
          return;
        }

        await _processBannerUpdate(id, collectionName, event, emit);
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

    // Handle explicit user state updates
    on<UpdateUserState>((event, emit) async {
      try {
        final user = event.user;
        if (user != null) {
          debugPrint(
              'Explicitly updating UserBloc state with provided user data');
          // Always set forceRefresh to true to ensure UI components refresh
          emit(UserLoaded(user, forceRefresh: true));
        } else {
          debugPrint('Cannot update UserBloc state: null user provided');
          emit(UserError('No user data provided for state update'));
        }
      } catch (e) {
        debugPrint('Error in UpdateUserState: $e');
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

  // Extract avatar update logic to a separate method
  Future<void> _processAvatarUpdate(String id, String collectionName,
      UpdateUserAvatar event, Emitter<UserState> emit) async {
    final pb = await PocketBaseSingleton.instance;

    debugPrint(
        'Updating avatar for user ID: $id in collection: $collectionName');

    if (event.avatar != null) {
      // Create a multipart file for the avatar upload
      final avatarFile = await event.avatar!.readAsBytes();
      final fileName = 'avatar.${event.avatar!.path.split('.').last}';

      debugPrint('Uploading avatar with filename: $fileName');
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
      debugPrint('Avatar upload successful');
    } else {
      debugPrint('No avatar file provided, skipping upload');
    }

    // Fetch the updated record
    debugPrint('Fetching updated user record');
    final updatedRecord = await pb.collection(collectionName).getOne(id);

    // Always set forceRefresh to true for immediate UI updates
    if (collectionName == 'brands') {
      final brand = Brand.fromRecord(updatedRecord);
      emit(UserLoaded(brand, forceRefresh: true));
    } else {
      final influencer = Influencer.fromRecord(updatedRecord);
      emit(UserLoaded(influencer, forceRefresh: true));
    }
  }

  // Extract banner update logic to a separate method
  Future<void> _processBannerUpdate(String id, String collectionName,
      UpdateUserBanner event, Emitter<UserState> emit) async {
    final pb = await PocketBaseSingleton.instance;

    debugPrint(
        'Updating banner for user ID: $id in collection: $collectionName');

    if (event.banner != null) {
      // Create a multipart file for the banner upload
      final bannerFile = await event.banner!.readAsBytes();
      final fileName = 'banner.${event.banner!.path.split('.').last}';

      debugPrint('Uploading banner with filename: $fileName');
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
      debugPrint('Banner upload successful');
    } else {
      debugPrint('No banner file provided, skipping upload');
    }

    // Fetch the updated record
    debugPrint('Fetching updated user record');
    final updatedRecord = await pb.collection(collectionName).getOne(id);

    // Always set forceRefresh to true for immediate UI updates
    if (collectionName == 'brands') {
      final brand = Brand.fromRecord(updatedRecord);
      emit(UserLoaded(brand, forceRefresh: true));
    } else {
      final influencer = Influencer.fromRecord(updatedRecord);
      emit(UserLoaded(influencer, forceRefresh: true));
    }
  }

  // Extract user update logic to a separate method that can be reused
  Future<void> _processUserUpdate(
      dynamic currentUser, UpdateUser event, Emitter<UserState> emit) async {
    // Log the user type to help with debugging
    debugPrint('Processing update for user type: ${currentUser.runtimeType}');

    final bool isBrand = currentUser is Brand;
    debugPrint('User is ${isBrand ? 'Brand' : 'Influencer'}');

    // More defensive check for userId
    final String? userId = currentUser?.id;
    if (userId == null || userId.isEmpty) {
      debugPrint('Cannot update: user id is null or empty');
      emit(UserError('User ID is missing'));
      return;
    }

    // Verify authentication status
    final pb = await PocketBaseSingleton.instance;
    if (!pb.authStore.isValid) {
      debugPrint('Cannot update: user is not authenticated');
      emit(UserError('Authentication required. Please log in again.'));
      return;
    }

    debugPrint(
        'Updating user with ID: $userId (${isBrand ? 'Brand' : 'Influencer'})');

    try {
      // Update user info
      if (isBrand) {
        // Update brand
        final Map<String, dynamic> data = {};

        if (event.brandName != null) {
          data['brandName'] = event.brandName;
          debugPrint('Setting brand name to: ${event.brandName}');
        }
        if (event.industry != null) {
          data['industry'] = event.industry;
          debugPrint('Setting industry to: ${event.industry}');
        }
        if (event.email != null) {
          data['email'] = event.email;
          debugPrint('Setting email to: ${event.email}');
        }

        debugPrint('Updating brand data: $data');

        if (data.isNotEmpty) {
          await BrandRepository.updateBrand(userId, data);
          debugPrint('Brand data updated successfully');
        } else {
          debugPrint('No brand data to update');
        }

        // Always update profile description if it's provided (even if empty)
        if (event.description != null) {
          debugPrint('Updating brand profile description');
          await BrandRepository.updateBrandProfile(
            brand: currentUser,
            description: event.description!,
          );
          debugPrint('Brand profile description updated successfully');
        }
      } else {
        // Update influencer
        final Map<String, dynamic> data = {};

        if (event.fullName != null) {
          data['fullName'] = event.fullName;
          debugPrint('Setting full name to: ${event.fullName}');
        }
        if (event.username != null) {
          data['username'] = event.username;
          debugPrint('Setting username to: ${event.username}');
        }
        if (event.industry != null) {
          data['industry'] = event.industry;
          debugPrint('Setting industry to: ${event.industry}');
        }
        if (event.email != null) {
          data['email'] = event.email;
          debugPrint('Setting email to: ${event.email}');
        }
        if (event.socialHandle != null) {
          data['socialHandle'] = event.socialHandle;
          debugPrint('Setting social handle to: ${event.socialHandle}');
        }

        debugPrint('Updating influencer data: $data');

        if (data.isNotEmpty) {
          await InfluencerRepository.updateInfluencer(userId, data);
          debugPrint('Influencer data updated successfully');
        } else {
          debugPrint('No influencer data to update');
        }

        // Always update profile description if it's provided (even if empty)
        if (event.description != null) {
          debugPrint('Updating influencer profile description');
          await InfluencerRepository.updateInfluencerProfile(
            influencer: currentUser as Influencer,
            description: event.description!,
          );
          debugPrint('Influencer profile description updated successfully');
        }
      }

      // Fetch the updated user to reflect changes - with a small delay to ensure backend is updated
      await Future.delayed(const Duration(milliseconds: 300));
      final collectionName = isBrand ? 'brands' : 'influencers';

      debugPrint(
          'Fetching updated user record from $collectionName with ID $userId');
      final updatedRecord = await pb.collection(collectionName).getOne(userId);
      debugPrint('Successfully fetched updated user record');

      // Show the data for debugging
      if (isBrand) {
        final Map<String, dynamic> data = updatedRecord.toJson();
        debugPrint('Updated brand data: $data');
        final brand = Brand.fromRecord(updatedRecord);
        debugPrint('Brand name from updated record: ${brand.brandName}');
        debugPrint('Emitting UserLoaded state with updated brand');
        emit(UserLoaded(brand, forceRefresh: true));
      } else {
        final Map<String, dynamic> data = updatedRecord.toJson();
        debugPrint('Updated influencer data: $data');
        final influencer = Influencer.fromRecord(updatedRecord);
        debugPrint(
            'Influencer name from updated record: ${influencer.fullName}');
        debugPrint('Emitting UserLoaded state with updated influencer');
        emit(UserLoaded(influencer, forceRefresh: true));
      }
    } catch (e) {
      debugPrint('Error in _processUserUpdate: $e');
      emit(UserError('Update failed: ${e.toString()}'));
    }
  }
}
