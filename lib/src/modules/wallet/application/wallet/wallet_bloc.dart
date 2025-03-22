import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/data/repositories/funds_repository.dart';
import '../../../../shared/domain/models/funds.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletInitial()) {
    on<WalletLoadFunds>(_onLoadFunds);
    on<WalletAddFunds>(_onAddFunds);
  }

  Future<void> _onAddFunds(
    WalletAddFunds event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletAddingFunds());
    try {
      final updatedFunds = await FundsRepository.addFunds(
        event.userId,
        event.amount,
      );
      emit(WalletFundsAdded(updatedFunds));
      emit(WalletLoaded(updatedFunds));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onLoadFunds(
    WalletLoadFunds event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final funds = await FundsRepository.getFundsForUser(event.userId);
      emit(WalletLoaded(funds));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
