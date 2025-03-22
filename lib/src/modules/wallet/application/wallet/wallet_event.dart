part of 'wallet_bloc.dart';

class WalletAddFunds extends WalletEvent {
  final String userId;
  final double amount;

  const WalletAddFunds({
    required this.userId,
    required this.amount,
  });

  @override
  List<Object> get props => [userId, amount];
}

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class WalletLoadFunds extends WalletEvent {
  final String userId;

  const WalletLoadFunds(this.userId);

  @override
  List<Object> get props => [userId];
}
