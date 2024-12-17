import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../services/storage/pb.dart';
import '../../../../shared/data/repositories/error_repo.dart';
import '../../../../shared/data/singletons/account_type.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/influencer.dart';

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
        String collectionName = CollectionNameSingleton.instance;
        await pb.collection(collectionName).subscribe(
          id,
          (e) {
            if (e.action == 'update') {
              debugPrint(e.record!.data.toString());
              if (e.record!.data['verified']) {
                add(EmailVerify());
              }
            }
          },
        );
        debugPrint('Subscribed to email verification updates');
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
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
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });
  }
}
