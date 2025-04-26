import 'package:bloc/bloc.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:flutter/material.dart';

import '../../../../shared/data/repositories/error_repo.dart';
import '../../data/helpers/validation/input_validation.dart';
import '../../data/repositories/auth_repo.dart';

part 'signup_event.dart';
part 'signup_state.dart';

/// A BLoC that manages the signup process.
///
/// This BLoC is responsible for managing the signup process.
/// It listens for events that are dispatched by the application and updates
/// the state of the application based on the event.
///
/// {@category Signup}
class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupInitial()) {
    on<SignupBrandSubmitted>((event, emit) async {
      emit(SignupLoading());

      String? error = InputValidation.validateBrandForm(
        email: event.email.toLowerCase(),
        brandName: event.brandName.toLowerCase(),
        password: event.password,
        industry: event.industry,
      );

      if (error != null) {
        emit(SignupFailure(error));
        return;
      }

      try {
        // First, unsubscribe from any existing realtime connections
        await PocketBaseSingleton.unsubscribeAll();

        // Create the account
        await AuthRepository.createBrandAccount(
          brandName: event.brandName,
          username: event.username.toLowerCase(),
          email: event.email.toLowerCase(),
          password: event.password,
          industry: event.industry,
        );

        // Emit success state
        emit(SignupSuccess(
          email: event.email,
        ));

        // Allow a small delay before login to ensure PocketBase has time to process
        await Future.delayed(Duration(milliseconds: 500));

        // Reset the PocketBase singleton to clear any existing auth state
        await PocketBaseSingleton.reset();

        // Login with the new account
        await AuthRepository.login(
            email: event.email,
            password: event.password,
            accountType: 'brands');

        debugPrint('Brand signup and login completed successfully');
      } catch (e) {
        debugPrint('Error during brand signup: $e');
        ErrorRepository errorRepo = ErrorRepository();
        emit(SignupFailure(errorRepo.handleError(e)));
      }
    });

    on<SignupInfluencerSubmitted>((event, emit) async {
      emit(SignupLoading());

      String? error = InputValidation.validateInfluencerForm(
        firstName: event.firstName,
        lastName: event.lastName,
        username: event.username,
        email: event.email,
        password: event.password,
        industry: event.industry,
      );

      if (error != null) {
        emit(SignupFailure(error));
        return;
      }

      try {
        // First, unsubscribe from any existing realtime connections
        await PocketBaseSingleton.unsubscribeAll();

        // Create the account
        await AuthRepository.createInfluencerAccount(
          fullName: '${event.firstName} ${event.lastName}',
          username: event.username,
          email: event.email,
          password: event.password,
          industry: event.industry,
        );

        // Emit success state
        emit(SignupSuccess(email: event.email));

        // Allow a small delay before login to ensure PocketBase has time to process
        await Future.delayed(Duration(milliseconds: 500));

        // Reset the PocketBase singleton to clear any existing auth state
        await PocketBaseSingleton.reset();

        // Login with the new account
        await AuthRepository.login(
            email: event.email,
            password: event.password,
            accountType: 'influencers');

        debugPrint('Influencer signup and login completed successfully');
      } catch (e) {
        debugPrint('Error during influencer signup: $e');
        ErrorRepository errorRepo = ErrorRepository();
        emit(SignupFailure(errorRepo.handleError(e)));
      }
    });

    on<InstagramSignup>((event, emit) async {
      emit(InstagramLoading());
      try {
        debugPrint('Instagram signup initiated');
        // Unsubscribe from any existing realtime connections
        await PocketBaseSingleton.unsubscribeAll();

        final Influencer influencer = await AuthRepository.instagramAuth(
            collectionName: event.accountType);

        // Verify the auth store is valid after Instagram auth
        final pb = await PocketBaseSingleton.instance;
        if (pb.authStore.isValid) {
          debugPrint('Instagram signup successful - Auth store is valid');
          emit(InstagramSignupSuccess(influencer: influencer));
        } else {
          debugPrint('Instagram signup failed - Auth store is not valid');
          emit(InstagramFailure(
              'Instagram authentication failed. Please try again.'));
        }
      } catch (e) {
        debugPrint('Error during Instagram signup: $e');
        ErrorRepository errorRepo = ErrorRepository();
        emit(InstagramFailure(errorRepo.handleError(e)));
      }
    });
  }
}
