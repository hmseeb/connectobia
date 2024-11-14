import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:flutter/material.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuth>((event, emit) async {
      emit(AuthLoading());
      try {
        User? user = await AuthRepo.getCurrentUser();
        if (user == null) {
          emit(Unauthenticated());
        } else {
          if (user.verified) {
            emit(Authenticated(user));
          } else {
            emit(Unverified(user.email));
          }
        }
      } catch (e) {
        emit(AuthFailed('Something went wrong, please try again.'));
      }
    });
  }
}
