import 'package:connectobia/modules/auth/data/respository/input_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShadInputFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            placeholder: const Text('Email'),
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
          placeholder: const Text('Password'),
          keyboardType: TextInputType.visiblePassword,
          suffix: GestureDetector(
            child: Icon(obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
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
