import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/helpers/validation/input_validation.dart';

/// A form that allows a Influencer to sign up.
/// [InfluencerSignupForm] contains fields for first name, last name, email, and password.
///
/// {@category Forms}
class InfluencerSignupForm extends StatefulWidget {
  final TextEditingController brandNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController usernameController;

  const InfluencerSignupForm(
      {super.key,
      required this.brandNameController,
      required this.emailController,
      required this.passwordController,
      required this.usernameController});

  @override
  State<InfluencerSignupForm> createState() => _InfluencerSignupFormState();
}

class _InfluencerSignupFormState extends State<InfluencerSignupForm> {
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
