import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShadInput(
          placeholder: Text('Email'),
          prefix: Icon(Icons.email_outlined),
        ),
        SizedBox(height: 10),
        ShadInput(
          placeholder: Text('Password'),
          prefix: Icon(Icons.lock_outline),
          suffix: Icon(Icons.visibility_off_outlined),
        ),
      ],
    );
  }
}
