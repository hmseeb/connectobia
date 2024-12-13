import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../common/singletons/account_type.dart';
import '../../data/respository/auth_repo.dart';
import '../../domain/model/brand.dart';
import '../../domain/model/influencer.dart';

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
        emit(Unauthenticated());
        await AuthRepo.logout();
      }
    });
  }
}
