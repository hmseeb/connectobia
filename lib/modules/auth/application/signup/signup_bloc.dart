import 'package:bloc/bloc.dart';
import 'package:connectobia/features/auth/data/respository/auth_repo.dart';
import 'package:connectobia/features/auth/data/respository/input_validation.dart';
import 'package:meta/meta.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupInitial()) {
    on<SignupBrandSubmitted>((event, emit) async {
      emit(SignupLoading());

      String? error = InputValidation.validateBrandForm(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        website: event.website ?? '',
        password: event.password,
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
          event.website ?? '',
          event.password,
          event.accountType,
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
        );
        emit(SignupSuccess());
      } catch (e) {
        emit(SignupFailure(e.toString()));
      }
    });
  }
}
