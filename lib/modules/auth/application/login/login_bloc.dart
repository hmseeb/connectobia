import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/data/respository/input_validation.dart';
import 'package:connectobia/modules/auth/domain/model/brand.dart';
import 'package:connectobia/modules/auth/domain/model/influencer.dart';
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

      if (event.accountType == null) {
        emit(LoginFailure('Account type is required'));
        return;
      }

      if (emailError != null || passwordError != null) {
        emit(LoginFailure(emailError ?? passwordError ?? ''));
        return;
      }

      emit(LoginLoading());

      try {
        final authData = await AuthRepo.login(
            email: event.email, password: event.password, accountType: 'brand');
        Brand user = Brand.fromJson(authData.record.data);
        // FIXME: This is a temporary fix.
        // bool isVerified = authData.record.data['verified'];
        bool isVerified = user.verified;
        // Brand user = await AuthRepo.getUser();
        if (isVerified) {
          emit(BrandLoginSuccess(user));
        } else {
          await AuthRepo.verifyEmail(email: event.email);
          emit(LoginUnverified());
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });

    on<LoginWithInstagram>((event, emit) async {
      emit(InstagramLoading());
      if (event.accountType == null) {
        return emit(LoginFailure('Account type is required'));
      }
      try {
        // FIXME: If above fixme works remove get user from this as well.
        await AuthRepo.loginWithInstagram(collectionName: event.accountType!);
        emit(InfluencerLoginSuccess(await AuthRepo.getUser()));
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}
