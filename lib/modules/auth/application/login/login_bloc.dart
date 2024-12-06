import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/data/respository/input_validation.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:meta/meta.dart';

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
        final authData = await AuthRepo.login(event.email, event.password);
        bool isVerified = authData.record.data['verified'];
        User user = await AuthRepo.getUser();
        if (isVerified) {
          emit(LoginSuccess(user));
        } else {
          await AuthRepo.verifyEmail(event.email);
          emit(LoginUnverified());
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });

    on<LoginWithInstagram>((event, emit) async {
      emit(InstagramLoading());
      try {
        await AuthRepo.authWithInstagram();
        emit(LoginSuccess(await AuthRepo.getUser()));
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}
