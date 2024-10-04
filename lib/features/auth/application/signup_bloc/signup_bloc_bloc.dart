import 'package:bloc/bloc.dart';
import 'package:connectobia/features/auth/data/respository/input_validation.dart';
import 'package:meta/meta.dart';

part 'signup_bloc_event.dart';
part 'signup_bloc_state.dart';

class SignupBloc extends Bloc<SignupBlocEvent, SignupBlocState> {
  SignupBloc() : super(SignupBlocInitial()) {
    on<SignupBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<EmailChangedEvent>((event, emit) {
      final emailError = InputValidation.validateEmail(event.email);
      if (emailError != null) {
        emit(SignupInvalidEmail(emailError));
      }
    });

    on<FirstNameChangedEvent>((event, emit) {
      final firstNameError = InputValidation.validateFirstName(event.firstName);
      if (firstNameError != null) {
        emit(SignupInvalidFirstName(firstNameError));
      }
    });
    on<LastNameChangedEvent>((event, emit) {
      final lastNameError = InputValidation.validateLastName(event.lastName);
      if (lastNameError != null) {
        emit(SignupInvalidLastName(lastNameError));
      }
    });
  }
}
