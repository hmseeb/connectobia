import 'package:bloc/bloc.dart';
import 'package:connectobia/src/db/db.dart';
import 'package:flutter/material.dart';

part 'email_verification_event.dart';
part 'email_verification_state.dart';

class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  EmailVerificationBloc() : super(EmailVerificationInitialState()) {
    on<EmailSubscribeEvent>((event, emit) async {
      try {
        final pb = await PocketBaseSingleton.instance;
        final id = pb.authStore.model.id;
        await pb.collection('users').subscribe(
          id,
          (e) {
            if (e.action == 'update') {
              if (e.record!.data['verified']) {
                add(EmailVerify());
              }
            }
          },
        );
        debugPrint('Subscribed to verification updates');
      } catch (e) {
        debugPrint(e.toString());
        rethrow;
      }
    });

    on<EmailVerify>((event, emit) async {
      try {
        final pb = await PocketBaseSingleton.instance;
        await pb.collection('users').unsubscribe();
        debugPrint('Unsubscribed to verification updates');
        emit(EmailVerified());
      } catch (e) {
        debugPrint(e.toString());
        rethrow;
      }
    });
  }
}