import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../common/domain/repositories/error_repository.dart';
import '../../data/respository/auth_repo.dart';
import '../../data/respository/input_validation.dart';

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
        email: event.email,
        brandName: event.brandName,
        password: event.password,
        industry: event.industry,
      );

      if (error != null) {
        emit(SignupFailure(error));
        return;
      }

      try {
        await AuthRepo.createBrandAccount(
          brandName: event.brandName,
          username: event.username,
          email: event.email,
          password: event.password,
          industry: event.industry,
        );
        emit(SignupSuccess(
          email: event.email,
        ));

        await AuthRepo.login(
            email: event.email, password: event.password, accountType: 'brand');
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
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
        await AuthRepo.createInfluencerAccount(
          fullName: '${event.firstName} ${event.lastName}',
          username: event.username,
          email: event.email,
          password: event.password,
          industry: event.industry,
        );
        emit(SignupSuccess(email: event.email));
        await AuthRepo.login(
            email: event.email,
            password: event.password,
            accountType: 'influencer');
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });

    on<InstagramSignup>((event, emit) async {
      emit(InstagramLoading());
      try {
        await AuthRepo.instagramAuth(collectionName: event.accountType);
        emit(SignupSuccess(
          email: null,
        ));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });
  }
}
