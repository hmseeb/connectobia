import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../shared/data/repositories/error_repo.dart';
import '../../../../shared/data/singletons/account_type.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../data/respositories/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    debugPrint(state.runtimeType.toString());
    on<CheckAuth>((event, emit) async {
      emit(AuthLoading());
      try {
        dynamic user = await AuthRepository.getUser();
        if (user == null) {
          return emit(Unauthenticated());
        }

        String accountType = CollectionNameSingleton.instance;
        if (user.verified) {
          if (accountType == 'brands') {
            emit(BrandAuthenticated(user));
          } else if (accountType == 'influencers') {
            emit(InfluencerAuthenticated(user));
          } else {
            emit(Unauthenticated());
          }
        } else {
          emit(Unverified(user.email));
        }
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(AuthError(errorRepo.handleError(e)));
      }
    });
  }
}
