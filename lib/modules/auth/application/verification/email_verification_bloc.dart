import 'package:bloc/bloc.dart';
import 'package:connectobia/common/singletons/account_type.dart';
import 'package:connectobia/db/db.dart';
import 'package:connectobia/modules/auth/domain/model/brand.dart';
import 'package:connectobia/modules/auth/domain/model/influencer.dart';
import 'package:flutter/material.dart';

part 'email_verification_event.dart';
part 'email_verification_state.dart';

/// A BLoC that manages the email verification process.
///
/// This BLoC is responsible for managing the email verification process.
/// It listens for events that are dispatched by the application and updates
///
/// {@category EmailVerification}
class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  EmailVerificationBloc() : super(EmailVerificationInitialState()) {
    on<EmailSubscribeEvent>((event, emit) async {
      try {
        final pb = await PocketBaseSingleton.instance;
        final id = pb.authStore.record!.id;
        await pb.collection(event.accountType).subscribe(
          id,
          (e) {
            if (e.action == 'update') {
              if (e.record!.data['verified']) {
                debugPrint('Email verified');
                add(EmailVerify());
              }
            }
          },
        );
        debugPrint('Subscribed to email verification updates');
      } catch (e) {
        debugPrint(e.toString());
        rethrow;
      }
    });

    on<EmailVerify>((event, emit) async {
      try {
        final pb = await PocketBaseSingleton.instance;
        String accountType = CollectionNameSingleton.instance;
        await pb.collection(accountType).unsubscribe();
        debugPrint('Unsubscribed to email verification updates');

        if (accountType == 'brand') {
          final Brand user = Brand.fromRecord(pb.authStore.record!);
          emit(BrandEmailVerified(user));
        } else if (accountType == 'influencer') {
          final Influencer user = Influencer.fromRecord(pb.authStore.record!);
          emit(InfluencerEmailVerified(user));
        }
      } catch (e) {
        debugPrint(e.toString());
        rethrow;
      }
    });
  }
}
