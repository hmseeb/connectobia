import 'package:connectobia/modules/auth/data/respository/input_validation.dart';
import 'package:connectobia/modules/auth/presentation/widgets/full_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A form that allows a brand to sign up.
/// [BrandSignupForm] contains fields for first name, last name, email, password, and website.
///
/// {@category Forms}
class BrandSignupForm extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController brandNameController;
  final TextEditingController passwordController;
  final Widget industry;
  const BrandSignupForm({
    super.key,
    required this.emailController,
    required this.brandNameController,
    required this.passwordController,
    required this.firstNameController,
    required this.lastNameController,
    required this.industry,
    required this.usernameController,
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
          lastName: widget.lastNameController,
          showLabels: false,
        ),
        ShadInputFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            placeholder: const Text('Username'),
            controller: widget.usernameController,
            keyboardType: TextInputType.name,
            validator: (value) {
              final error = InputValidation.validateUsername(value);
              if (error != null) {
                return error;
              }
              return null;
            }),
        ShadInputFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            placeholder: const Text('Brand Name'),
            keyboardType: TextInputType.name,
            controller: widget.brandNameController,
            validator: (value) {
              final error = InputValidation.validateBrandName(value);
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
        widget.industry,
      ],
    );
  }
}
