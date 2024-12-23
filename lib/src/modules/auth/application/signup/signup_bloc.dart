import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

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
        await AuthRepository.createBrandAccount(
          brandName: event.brandName,
          username: event.username.toLowerCase(),
          email: event.email.toLowerCase(),
          password: event.password,
          industry: event.industry,
        );
        emit(SignupSuccess(
          email: event.email,
        ));

        await AuthRepository.login(
            email: event.email,
            password: event.password,
            accountType: 'brands');
      } catch (e) {
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
        await AuthRepository.createInfluencerAccount(
          fullName: '${event.firstName} ${event.lastName}',
          username: event.username,
          email: event.email,
          password: event.password,
          industry: event.industry,
        );
        emit(SignupSuccess(email: event.email));
        await AuthRepository.login(
            email: event.email,
            password: event.password,
            accountType: 'influencers');
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(SignupFailure(errorRepo.handleError(e)));
      }
    });

    on<InstagramSignup>((event, emit) async {
      emit(InstagramLoading());
      try {
        await AuthRepository.instagramAuth(collectionName: event.accountType);
        emit(SignupSuccess(
          email: null,
        ));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(SignupFailure(errorRepo.handleError(e)));
      }
    });
  }
}
