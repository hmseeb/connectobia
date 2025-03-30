import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../auth/data/helpers/validation/input_validation.dart';
import '../../application/user/user_bloc.dart';

/// A sheet that allows the user to change their email address.
///
/// [ChangeEmailSheet] contains a form for the user to enter a new email
/// address and request verification.
///
/// {@category Sheets}
class ChangeEmailSheet extends StatefulWidget {
  final ShadSheetSide side;
  final String currentEmail;

  const ChangeEmailSheet(
      {super.key, required this.side, required this.currentEmail});

  @override
  State<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<ChangeEmailSheet> {
  late final TextEditingController emailController;
  bool isLoading = false;
  String? errorMessage;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is EmailChangeRequested) {
          // Email change request was successful
          setState(() {
            isLoading = false;
          });
          // Close the sheet
          Navigator.pop(context);

          // Show success toast
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Verification email sent!'),
              description: Text(
                  'Please check your inbox to confirm your new email address.'),
            ),
          );
        } else if (state is UserError) {
          // Email change request failed
          setState(() {
            isLoading = false;
            errorMessage = state.message;
          });

          // Show error toast
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Failed to request email change'),
              description: Text(state.message),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sheet header with drag handle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              // Title
              const Text(
                'Change Email Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              const Text(
                'Enter your new email address. We will send a verification link to confirm your new email.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Current email display (adding this back for clarity)
              Text(
                'Current email: ${widget.currentEmail}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),

              // New email input
              ShadInputFormField(
                autofocus: true,
                controller: emailController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                id: 'New Email',
                keyboardType: TextInputType.emailAddress,
                label: const Text('New Email'),
                placeholder: const Text('Enter your new email'),
                validator: validateEmail,
              ),

              // Error message
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Action buttons
              ShadButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        final newEmail = emailController.text.trim();

                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });

                        try {
                          // Log debug info
                          debugPrint('Requesting email change to: $newEmail');

                          // Request email change using the BLoC
                          context.read<UserBloc>().add(
                                RequestEmailChange(newEmail: newEmail),
                              );
                        } catch (e) {
                          // Handle any immediate errors
                          debugPrint('Direct error handling: $e');
                          setState(() {
                            isLoading = false;
                            errorMessage = e.toString();
                          });

                          if (context.mounted) {
                            ShadToaster.of(context).show(
                              ShadToast.destructive(
                                title: const Text(
                                    'Failed to request email change'),
                                description: Text(e.toString()),
                              ),
                            );
                          }
                        }
                      },
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: shadTheme.brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                        ),
                      )
                    : const Text('Send Verification'),
              ),

              const SizedBox(height: 8),

              // Cancel button
              ShadButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();

    // Force fetch user to ensure it's loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<UserBloc>().state;
      if (userState is! UserLoaded) {
        context.read<UserBloc>().add(FetchUser());
      }
    });
  }

  // Validate email with additional checks
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final basicValidation = InputValidation.validateEmail(value);
    if (basicValidation != null) {
      return basicValidation;
    }

    if (value.trim() == widget.currentEmail.trim()) {
      return 'New email must be different from current email';
    }

    return null;
  }
}
