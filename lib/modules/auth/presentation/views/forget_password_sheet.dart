import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/data/respository/input_validation.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A sheet that allows the user to reset their password.
///
/// [ForgotPasswordSheet] contains a form for the user to enter their email to receive a password reset link.
///
/// {@category Sheets}
class ForgotPasswordSheet extends StatefulWidget {
  final ShadSheetSide side;
  final String accountType;

  const ForgotPasswordSheet(
      {super.key, required this.side, required this.accountType});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  late final TextEditingController emailController;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);
    return ShadSheet(
      constraints: widget.side == ShadSheetSide.left ||
              widget.side == ShadSheetSide.right
          ? const BoxConstraints(maxWidth: 512)
          : null,
      title: const Text('Reset Password'),
      actions: [
        ShadButton(
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
              : const Text('Send Email'),
          onPressed: () async {
            final value = emailController.text;
            final error = InputValidation.validateEmail(value);
            if (error != null) {
              return ShadToaster.of(context).show(
                ShadToast.destructive(
                  title: Text(error),
                ),
              );
            }

            setState(() {
              isLoading = true;
            });
            try {
              await AuthRepo.forgotPassword(
                email: emailController.text,
                collectionName: widget.accountType,
              );
              if (context.mounted) {
                ShadToaster.of(context).show(
                  const ShadToast(
                      title: Text(
                          'If the email exists, you will receive a link to reset your password.')),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              if (context.mounted) {
                ShadToaster.of(context).show(
                  ShadToast.destructive(
                    title: const Text('An error occured while sending email'),
                    description: Text(e.toString()),
                  ),
                );
              }
              throw throw ClientException(originalError: e);
            }
            setState(() {
              isLoading = false;
            });
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShadInputFormField(
                  autofocus: true,
                  controller: emailController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  id: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  label: const Text('Email'),
                  placeholder: const Text('Enter your email'),
                  validator: (value) {
                    final error = InputValidation.validateEmail(value);
                    if (error != null) {
                      return error;
                    }
                    return null;
                  }),
            ]),
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
  }
}
