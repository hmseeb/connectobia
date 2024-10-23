import 'package:connectobia/src/modules/auth/data/respository/input_validation.dart';
import 'package:connectobia/src/modules/auth/presentation/widgets/firstlast_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BrandSignupForm extends StatefulWidget {
  final TextEditingController firstNameController;

  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController websiteController;
  final TextEditingController passwordController;
  const BrandSignupForm({
    super.key,
    required this.emailController,
    required this.websiteController,
    required this.passwordController,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  State<BrandSignupForm> createState() => _BrandSignupFormState();
}

class _BrandSignupFormState extends State<BrandSignupForm> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FirstLastName(
            firstName: widget.firstNameController,
            lastName: widget.lastNameController),
        ShadInputFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            placeholder: const Text('Email*'),
            controller: widget.emailController,
            validator: (value) {
              final error = InputValidation.validateEmail(value);
              if (error != null) {
                return error;
              }
              return null;
            }),
        ShadInputFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            placeholder: const Text('Business Website (optional)'),
            controller: widget.websiteController,
            validator: (value) {
              final error = InputValidation.validateWebsite(value);
              if (error != null) {
                return error;
              }
              return null;
            }),
        ShadInputFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          placeholder: const Text('Password*'),
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
