import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../services/storage/pb.dart';
import '../../../../shared/data/constants/industries.dart';
import '../../../../shared/data/repositories/error_repo.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/brand_profile.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../../../shared/domain/models/influencer_profile.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<FetchUser>((event, emit) async {
      emit(UserLoading());
      try {
        final pb = await PocketBaseSingleton.instance;
        if (!pb.authStore.isValid) {
          emit(UserError('User not authenticated'));
          return;
        }

        final id = pb.authStore.record!.id;
        final collectionName = pb.authStore.record!.collectionName;

        final record = await pb.collection(collectionName).getOne(id);

        if (collectionName == 'brands') {
          final brand = Brand.fromRecord(record);
          emit(UserLoaded(brand));
        } else {
          final influencer = Influencer.fromRecord(record);
          emit(UserLoaded(influencer));
        }
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(UserError(errorRepo.handleError(e)));
      }
    });

    on<FetchUserProfile>((event, emit) async {
      emit(UserLoading());
      try {
        final pb = await PocketBaseSingleton.instance;

        // First get the current user
        if (!pb.authStore.isValid) {
          emit(UserError('User not authenticated'));
          return;
        }

        final id = pb.authStore.record!.id;
        final collectionName = pb.authStore.record!.collectionName;
        final userRecord = await pb.collection(collectionName).getOne(id);

        // Then get the profile data
        final profileCollectionName =
            event.isBrand ? 'brandProfile' : 'influencerProfile';
        final profileRecord =
            await pb.collection(profileCollectionName).getOne(event.profileId);

        debugPrint('Fetched profile data: ${profileRecord.data}');

        if (event.isBrand) {
          final brand = Brand.fromRecord(userRecord);
          final brandProfile = BrandProfile.fromRecord(profileRecord);
          emit(UserProfileLoaded(user: brand, profileData: brandProfile));
        } else {
          final influencer = Influencer.fromRecord(userRecord);
          final influencerProfile = InfluencerProfile.fromRecord(profileRecord);
          emit(UserProfileLoaded(
              user: influencer, profileData: influencerProfile));
        }
      } catch (e) {
        debugPrint('Error fetching profile: $e');
        ErrorRepository errorRepo = ErrorRepository();
        emit(UserError(errorRepo.handleError(e)));
      }
    });

    on<UpdateUser>((event, emit) async {
      emit(UserUpdating());
      try {
        final pb = await PocketBaseSingleton.instance;
        final id = pb.authStore.record!.id;
        final collectionName = pb.authStore.record!.collectionName;

        // Create body for main collection update
        final body = <String, dynamic>{};

        if (event.fullName != null) body['fullName'] = event.fullName;
        if (event.username != null) body['username'] = event.username;
        if (event.email != null) body['email'] = event.email;
        if (event.industry != null) {
          body['industry'] = IndustryFormatter.keyToValue(event.industry!);
        }
        if (event.socialHandle != null) {
          body['socialHandle'] = event.socialHandle;
        }
        if (collectionName == 'brands' && event.brandName != null) {
          body['brandName'] = event.brandName;
        }

        // Update the main user document if there are fields to update
        if (body.isNotEmpty) {
          await pb.collection(collectionName).update(id, body: body);
        }

        // If description is provided, update the profile collection
        if (event.description != null) {
          // Get the profile ID from the user record
          final userRecord = await pb.collection(collectionName).getOne(id);
          final profileId = userRecord.data["profile"];

          // Determine which profile collection to update
          final profileCollectionName =
              collectionName == 'brands' ? 'brandProfile' : 'influencerProfile';

          // Update the description in the profile collection
          await pb.collection(profileCollectionName).update(
            profileId,
            body: {"description": event.description},
          );
        }

        // Fetch the updated user
        final updatedUserRecord =
            await pb.collection(collectionName).getOne(id);

        if (collectionName == 'brands') {
          final brand = Brand.fromRecord(updatedUserRecord);
          emit(UserLoaded(brand));
        } else {
          final influencer = Influencer.fromRecord(updatedUserRecord);
          emit(UserLoaded(influencer));
        }
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(UserError(errorRepo.handleError(e)));
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
        final List<http.MultipartFile> files = [];

        if (event.avatar != null) {
          final bytes = await event.avatar!.readAsBytes();
          final fileName = event.avatar!.name;

          final avatarFile = http.MultipartFile.fromBytes(
            'avatar',
            bytes,
            filename: fileName,
          );

          files.add(avatarFile);
        }

        final updatedRecord = await pb.collection(collectionName).update(
              id,
              body: formData,
              files: files,
            );

        if (collectionName == 'brands') {
          final brand = Brand.fromRecord(updatedRecord);
          emit(UserLoaded(brand));
        } else {
          final influencer = Influencer.fromRecord(updatedRecord);
          emit(UserLoaded(influencer));
        }
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(UserError(errorRepo.handleError(e)));
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
        final List<http.MultipartFile> files = [];

        if (event.banner != null) {
          final bytes = await event.banner!.readAsBytes();
          final fileName = event.banner!.name;

          final bannerFile = http.MultipartFile.fromBytes(
            'banner',
            bytes,
            filename: fileName,
          );

          files.add(bannerFile);
        }

        final updatedRecord = await pb.collection(collectionName).update(
              id,
              body: formData,
              files: files,
            );

        if (collectionName == 'brands') {
          final brand = Brand.fromRecord(updatedRecord);
          emit(UserLoaded(brand));
        } else {
          final influencer = Influencer.fromRecord(updatedRecord);
          emit(UserLoaded(influencer));
        }
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(UserError(errorRepo.handleError(e)));
      }
    });
  }
}
