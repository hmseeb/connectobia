import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../services/storage/pb.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../data/helpers/validation/input_validation.dart';
import '../../data/repositories/auth_repo.dart';
import '../../data/repositories/device_info.dart';

part 'login_bloc_event.dart';
part 'login_bloc_state.dart';

/// A BLoC that manages the login process.
///
/// This BLoC is responsible for managing the login process.
/// It listens for events that are dispatched by the application and updates
/// the state of the application based on the event.
///
/// {@category Login}
class LoginBloc extends Bloc<LoginBlocEvent, LoginBlocState> {
  LoginBloc() : super(LoginBlocInitial()) {
    on<LoginSubmitted>((event, emit) async {
      String? emailError = InputValidation.validateEmail(event.email);
      String? passwordError =
          InputValidation.validatePassword(event.password).firstOrNull;

      if (emailError != null || passwordError != null) {
        emit(LoginFailure(emailError ?? passwordError ?? ''));
        return;
      }

      emit(LoginLoading());

      try {
        final authData = await AuthRepository.login(
            email: event.email.toLowerCase(),
            password: event.password,
            accountType: event.accountType);

        if (event.accountType == 'influencers') {
          Influencer user = Influencer.fromJson(authData.record.data);
          bool isVerified = user.verified;
          if (isVerified) {
            emit(InfluencerLoginSuccess(user));
          } else {
            await AuthRepository.verifyEmail(email: event.email.toLowerCase());
            emit(LoginUnverified());
          }
        } else {
          Brand user = Brand.fromJson(authData.record.data);
          bool isVerified = user.verified;
          if (isVerified) {
            emit(BrandLoginSuccess(user));
          } else {
            await AuthRepository.verifyEmail(email: event.email.toLowerCase());
            emit(LoginUnverified());
          }
        }

        DeviceInfoRepository infoRepo = DeviceInfoRepository();
        final Map<String, dynamic> info = await infoRepo.fetchDeviceInfo();

        await AuthRepository.createLoginHistory(
            userId: authData.record.id, deviceInfo: info);
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });

    on<InstagramAuth>((event, emit) async {
      emit(InstagramLoading());
      try {
        debugPrint('Logging in with Instagram - start');

        // Reset PocketBase singleton first to ensure a clean auth state
        debugPrint('Resetting PocketBase singleton before Instagram auth');
        await PocketBaseSingleton.reset();

        // Clear any existing PocketBase auth state
        await PocketBaseSingleton.unsubscribeAll();

        final influencer = await AuthRepository.instagramAuth(
          collectionName: event.accountType,
        );

        // Verify the auth store is valid after Instagram auth
        final pb = await PocketBaseSingleton.instance;
        debugPrint(
            'Auth store token after Instagram auth: ${pb.authStore.token}');

        if (pb.authStore.isValid) {
          debugPrint('Instagram auth successful - Auth store is valid');
          debugPrint('User authenticated as: ${influencer.email}');

          // Force a small delay to ensure token is saved
          await Future.delayed(Duration(milliseconds: 500));

          emit(InfluencerLoginSuccess(influencer));
        } else {
          debugPrint('Instagram auth failed - Auth store is not valid');
          emit(InstagramFailure(
              'Instagram authentication failed. Please try again.'));
        }
      } catch (e) {
        debugPrint('Instagram auth error: $e');
        emit(InstagramFailure(e.toString()));
      }
    });
  }
}
