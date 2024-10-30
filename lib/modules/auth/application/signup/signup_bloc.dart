import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/data/respository/input_validation.dart';
import 'package:meta/meta.dart';

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
        firstName: event.firstName,
        lastName: event.lastName,
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
        await AuthRepo.createAccount(
          event.firstName,
          event.lastName,
          event.email,
          event.brandName,
          event.password,
          event.accountType,
          event.industry,
        );
        emit(SignupSuccess());
      } catch (e) {
        emit(SignupFailure(e.toString()));
      }
    });

    on<SignupInfluencerSubmitted>((event, emit) async {
      emit(SignupLoading());

      String? error = InputValidation.validateInfluencerForm(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        industry: event.industry,
      );

      if (error != null) {
        emit(SignupFailure(error));
        return;
      }

      try {
        await AuthRepo.createAccount(
          event.firstName,
          event.lastName,
          event.email,
          '',
          event.password,
          'influencer',
          event.industry,
        );
        emit(SignupSuccess());
      } catch (e) {
        emit(SignupFailure(e.toString()));
      }
    });
  }
}
