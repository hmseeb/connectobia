import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/src/modules/auth/data/respository/input_validation.dart';
import 'package:meta/meta.dart';

part 'login_bloc_event.dart';
part 'login_bloc_state.dart';

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
        await AuthRepo.login(event.email, event.password);
        emit(LoginSuccess());
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}
