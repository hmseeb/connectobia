import 'package:connectobia/features/auth/presentation/widgets/firstlast_name.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreatorSignupForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  const CreatorSignupForm(
      {super.key,
      required this.firstNameController,
      required this.lastNameController,
      required this.emailController,
      required this.passwordController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FirstLastName(
            firstName: firstNameController, lastName: lastNameController),
        ShadInput(
          placeholder: const Text('Email*'),
          controller: emailController,
        ),
        ShadInput(
          placeholder: const Text('Password*'),
          suffix: const Icon(Icons.visibility_off_outlined),
          controller: passwordController,
        ),
      ],
    );
  }
}
