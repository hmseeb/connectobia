import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/helpers/validation/input_validation.dart';

/// A form that allows a creator to sign up.
/// [CreatorSignupForm] contains fields for first name, last name, email, and password.
///
/// {@category Forms}
class CreatorSignupForm extends StatefulWidget {
  final TextEditingController brandNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController usernameController;

  const CreatorSignupForm(
      {super.key,
      required this.brandNameController,
      required this.emailController,
      required this.passwordController,
      required this.usernameController});

  @override
  State<CreatorSignupForm> createState() => _CreatorSignupFormState();
}

class _CreatorSignupFormState extends State<CreatorSignupForm> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShadInputFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          placeholder: const Text('Full Name'),
          controller: widget.brandNameController,
          keyboardType: TextInputType.name,
          validator: (value) {
            final error = InputValidation.validateName(value);
            if (error != null) {
              return error;
            }
            return null;
          },
        ),
        ShadInputFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            placeholder: const Text('Username'),
            controller: widget.usernameController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final error = InputValidation.validateUsername(value);
              if (error != null) {
                return error;
              }
              return null;
            }),
        ShadInputFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            placeholder: const Text('Email'),
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final error = InputValidation.validateEmail(value);
              if (error != null) {
                return error;
              }
              return null;
            }),
        ShadInputFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          placeholder: const Text('Password'),
          keyboardType: TextInputType.visiblePassword,
          suffix: GestureDetector(
            child: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onTap: () {
              HapticFeedback.mediumImpact();

              setState(() {
                obscureText = !obscureText;
              });
            },
          ),
          controller: widget.passwordController,
          validator: (value) {
            List<String> passwordErrors =
                InputValidation.validatePassword(value);
            if (passwordErrors.isNotEmpty) {
              return passwordErrors.join("\n");
            }
            return null;
          },
          obscureText: obscureText,
        ),
      ],
    );
  }
}
