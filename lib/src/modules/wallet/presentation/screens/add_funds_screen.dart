import 'package:connectobia/src/shared/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/presentation/widgets/transparent_app_bar.dart';
import '../../application/wallet/wallet_bloc.dart';

class AddFundsScreen extends StatefulWidget {
  final String userId;

  const AddFundsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isAddingFunds = false;
  late WalletBloc _walletBloc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => _walletBloc,
      child: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletFundsAdded) {
            // Show success toast
            ShadToaster.of(context).show(
              const ShadToast(
                title: Text('Success!'),
                description: Text('Funds added successfully'),
              ),
            );

            // Return to previous screen after a brief delay
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                Navigator.pop(context, state.funds);
              }
            });
          } else if (state is WalletError) {
            // Show error dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Error',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text('Error adding funds: ${state.message}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );

            setState(() {
              _isAddingFunds = false;
            });
          }
        },
        builder: (context, state) {
          // Update loading state based on bloc state
          if (state is WalletAddingFunds) {
            _isAddingFunds = true;
          }

          return Scaffold(
            appBar: transparentAppBar('Add Funds', context: context),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Funds illustration
                  Center(
                    child: Container(
                      height: 150,
                      width: 150,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter Fund Details',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShadInputFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    prefix: const Text('PKR',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    placeholder: const Text('5000.00'),
                  ),
                  const SizedBox(height: 24),
                  ShadCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Card Number',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ShadInputFormField(
                          controller: _cardNumberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            _CardNumberFormatter(),
                          ],
                          placeholder: const Text('4242 4242 4242 4242'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Expiry Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ShadInputFormField(
                                    controller: _expiryController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                      _ExpiryDateFormatter(),
                                    ],
                                    placeholder: const Text('MM/YY'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'CVV',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ShadInputFormField(
                                    controller: _cvvController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    placeholder: const Text('123'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Cardholder Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ShadInputFormField(
                          controller: _nameController,
                          placeholder: const Text('John Doe'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Note: This is for demonstration purposes only. No real payments will be processed.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ShadButton(
                      onPressed: _isAddingFunds ? null : _addFunds,
                      child: _isAddingFunds
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('PROCESSING...'),
                              ],
                            )
                          : const Text('ADD FUNDS'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _walletBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _walletBloc = WalletBloc();
  }

  Future<void> _addFunds() async {
    // Validate amount
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showErrorToast('Please enter a valid amount');
      return;
    }

    // Validate card number (16 digits)
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    if (cardNumber.length != 16) {
      _showErrorToast('Please enter a valid 16-digit card number');
      return;
    }

    // Validate expiry date (MM/YY)
    final expiry = _expiryController.text;
    if (expiry.length != 5 || !expiry.contains('/')) {
      _showErrorToast('Please enter a valid expiry date (MM/YY)');
      return;
    }

    // Validate CVV (3 digits)
    if (_cvvController.text.length != 3) {
      _showErrorToast('Please enter a valid 3-digit CVV');
      return;
    }

    // Validate cardholder name
    if (_nameController.text.trim().isEmpty) {
      _showErrorToast('Please enter the cardholder name');
      return;
    }

    setState(() {
      _isAddingFunds = true;
    });

    // Use the bloc to add funds
    _walletBloc.add(
      WalletAddFunds(
        userId: widget.userId,
        amount: amount,
      ),
    );
  }

  void _showErrorToast(String message) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: Text('Validation Error'),
        description: Text(message),
      ),
    );
  }
}

// Custom formatter for credit card number
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Custom formatter for expiry date (MM/YY)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && i != text.length - 1) {
        buffer.write('/');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
