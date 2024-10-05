import 'package:connectobia/features/auth/data/respository/input_validation.dart';
import 'package:connectobia/features/auth/presentation/widgets/firstlast_name.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BrandSignupForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        FirstLastName(
            firstName: firstNameController, lastName: lastNameController),
        ShadInputFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            placeholder: const Text('Email*'),
            controller: emailController,
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
            controller: websiteController,
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
          suffix: const Icon(Icons.visibility_off_outlined),
          controller: passwordController,
          validator: (value) {
            List<String> passwordErrors =
                InputValidation.validatePassword(value);
            if (passwordErrors.isNotEmpty) {
              return passwordErrors.join("\n");
            }
            return null;
          },
        ),
      ],
    );
  }
}
