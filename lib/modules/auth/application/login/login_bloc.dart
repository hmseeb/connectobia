import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../common/domain/repositories/error_repository.dart';
import '../../data/respository/auth_repo.dart';
import '../../data/respository/input_validation.dart';
import '../../domain/model/brand.dart';
import '../../domain/model/influencer.dart';

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
        final authData = await AuthRepo.login(
            email: event.email,
            password: event.password,
            accountType: event.accountType);

        if (event.accountType == 'influencer') {
          Influencer user = Influencer.fromJson(authData.record.data);
          bool isVerified = user.verified;
          if (isVerified) {
            emit(InfluencerLoginSuccess(user));
          } else {
            await AuthRepo.verifyEmail(email: event.email);
            emit(LoginUnverified());
          }
        } else {
          Brand user = Brand.fromJson(authData.record.data);
          // FIXME: This is a temporary fix.
          // bool isVerified = authData.record.data['verified'];
          bool isVerified = user.verified;
          if (isVerified) {
            emit(BrandLoginSuccess(user));
          } else {
            await AuthRepo.verifyEmail(email: event.email);
            emit(LoginUnverified());
          }
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });

    on<InstagramAuth>((event, emit) async {
      emit(InstagramLoading());
      try {
        debugPrint('Logging in with Instagram');
        final influencer =
            await AuthRepo.instagramAuth(collectionName: event.accountType);

        emit(InfluencerLoginSuccess(influencer));
        debugPrint('Logged in with Instagram');
      } catch (e) {
        emit(LoginFailure(e.toString()));
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });
  }
}
