import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../shared/data/repositories/error_repo.dart';
import '../../../../shared/data/singletons/account_type.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../data/repositories/auth_repo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuth>((event, emit) async {
      emit(AuthLoading());
      debugPrint("AuthLoading");
      try {
        debugPrint("Attempting to get user");
        dynamic user = await AuthRepository.getUser();
        debugPrint(
            "User retrieval result: ${user != null ? 'success' : 'null'}");

        if (user == null) {
          debugPrint("User is null, emitting Unauthenticated");
          return emit(Unauthenticated());
        }

        String accountType = CollectionNameSingleton.instance;
        debugPrint("User is $accountType");

        if (user.verified) {
          debugPrint("User is verified");
          if (accountType == 'brands') {
            debugPrint("Emitting BrandAuthenticated");
            emit(BrandAuthenticated(user));
          } else if (accountType == 'influencers') {
            debugPrint("Emitting InfluencerAuthenticated");
            emit(InfluencerAuthenticated(user));
          } else {
            debugPrint("Unknown account type, emitting Unauthenticated");
            emit(Unauthenticated());
          }
        } else {
          debugPrint(
              "User is not verified, emitting Unverified with email: ${user.email}");
          emit(Unverified(user.email));
        }
      } catch (e) {
        debugPrint("Auth error: $e");
        ErrorRepository errorRepo = ErrorRepository();
        emit(AuthError(errorRepo.handleError(e)));
      }
    });
  }
}
