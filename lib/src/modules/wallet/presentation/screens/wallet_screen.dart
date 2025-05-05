import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/domain/models/funds.dart';
import '../../../../shared/presentation/widgets/transparent_app_bar.dart';
import '../../application/wallet/wallet_bloc.dart';
import 'add_funds_screen.dart';

class WalletScreen extends StatefulWidget {
  final String userId;

  const WalletScreen({
    super.key,
    required this.userId,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late WalletBloc _walletBloc;
  Funds? _currentFunds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _walletBloc,
      child: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is WalletFundsAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funds added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is WalletLoaded) {
            // Store current funds for returning when popping
            _currentFunds = state.funds;
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              // Return funds to previous screen when popping
              if (_currentFunds != null) {
                Navigator.pop(context, _currentFunds);
              }
              return true;
            },
            child: Scaffold(
              appBar: transparentAppBar(
                'Wallet',
                context: context,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Return funds to previous screen
                    if (_currentFunds != null) {
                      Navigator.pop(context, _currentFunds);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              body: _buildBody(state),
              floatingActionButton: FloatingActionButton(
                onPressed: _navigateToAddFunds,
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _walletBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _walletBloc = WalletBloc()..add(WalletLoadFunds(widget.userId));
  }

  Widget _buildBalanceCard(Funds funds) {
    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Balance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'PKR ${funds.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ShadButton(
                onPressed: _navigateToAddFunds,
                child: const Text('Add Funds'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(WalletState state) {
    if (state is WalletLoading || state is WalletInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is WalletError) {
      return _buildErrorWidget(state.message);
    } else if (state is WalletLoaded) {
      return _buildWalletContent(state.funds);
    }

    // Default case, should rarely happen
    return const Center(child: Text('Something went wrong'));
  }

  Widget _buildDetailCard({
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.blue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading wallet: $errorMessage',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ShadButton(
            onPressed: () => _walletBloc.add(WalletLoadFunds(widget.userId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletContent(Funds funds) {
    return RefreshIndicator(
      onRefresh: () async {
        _walletBloc.add(WalletLoadFunds(widget.userId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBalanceCard(funds),
          const SizedBox(height: 16),
          _buildDetailCard(
            title: 'Available Balance',
            value: 'PKR ${funds.availableBalance.toStringAsFixed(2)}',
            icon: Icons.account_balance_wallet,
            iconColor: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            title: 'Locked Funds',
            value: 'PKR ${funds.locked.toStringAsFixed(2)}',
            icon: Icons.lock,
            iconColor: Colors.orange,
          ),
          const SizedBox(height: 24),
          const Text(
            'What are locked funds?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Locked funds are reserved for ongoing campaign contracts. When you create a campaign and sign a contract with an influencer, the payment amount is locked from your balance to ensure payment can be made once the campaign is completed.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Transaction History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Placeholder for future transaction history implementation
          ShadCard(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add funds to your wallet to see your transaction history',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddFunds() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFundsScreen(userId: widget.userId),
      ),
    );

    if (result != null && result is Funds) {
      // Use bloc to update the state
      _walletBloc.add(WalletLoadFunds(widget.userId));
    }
  }
}
