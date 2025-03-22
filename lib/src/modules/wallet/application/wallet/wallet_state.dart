part of 'wallet_bloc.dart';

class WalletAddingFunds extends WalletState {}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletFundsAdded extends WalletState {
  final Funds funds;

  const WalletFundsAdded(this.funds);

  @override
  List<Object?> get props => [funds];
}

class WalletInitial extends WalletState {}

class WalletLoaded extends WalletState {
  final Funds funds;

  const WalletLoaded(this.funds);

  @override
  List<Object?> get props => [funds];
}

class WalletLoading extends WalletState {}

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}
