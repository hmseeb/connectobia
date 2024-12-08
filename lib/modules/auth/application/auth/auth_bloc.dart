import 'package:bloc/bloc.dart';
import 'package:connectobia/common/singletons/account_type.dart';
import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/domain/model/brand.dart';
import 'package:connectobia/modules/auth/domain/model/influencer.dart';
import 'package:flutter/material.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    debugPrint(state.runtimeType.toString());
    on<CheckAuth>((event, emit) async {
      emit(AuthLoading());
      try {
        dynamic user = await AuthRepo.getUser();
        if (user == null) {
          return emit(Unauthenticated());
        }
        String accountType = CollectionNameSingleton.instance;
        if (user.verified) {
          if (accountType == 'brand') {
            emit(BrandAuthenticated(user));
          } else if (accountType == 'influencer') {
            emit(InfluencerAuthenticated(user));
          } else {
            emit(Unauthenticated());
          }
        } else {
          emit(Unverified(user.email));
        }
      } catch (e) {
        emit(AuthFailed('Something went wrong, please try again later.'));
        if (e.toString().contains('404')) {
          await AuthRepo.logout();
          emit(Unauthenticated());
        } else {
          throw Exception(e);
        }
      }
    });
  }
}
