import 'package:bloc/bloc.dart';
import 'package:connectobia/db/db.dart';
import 'package:connectobia/modules/auth/domain/model/brand.dart';
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
        await pb.collection('brand').subscribe(
          id,
          (e) {
            if (e.action == 'update') {
              debugPrint('Verification status updated');
              if (e.record!.data['verified']) {
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
        await pb.collection('brand').unsubscribe();
        debugPrint('Unsubscribed to email verification updates');
        final Brand user = Brand.fromRecord(pb.authStore.record!);
        emit(BrandEmailVerified(user));
      } catch (e) {
        debugPrint(e.toString());
        rethrow;
      }
    });
  }
}
