import 'package:connectobia/modules/auth/data/respository/input_validation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A form that allows a user to sign up.
/// [SignupForm] contains fields for first name, last name, email, and password.
///
/// {@category Forms}
class FirstLastName extends StatelessWidget {
  final TextEditingController firstName, lastName;
  const FirstLastName({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadInputFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  placeholder: const Text('First Name'),
                  controller: firstName,
                  validator: (value) {
                    final error = InputValidation.validateFirstName(value);
                    if (error != null) {
                      return error;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadInputFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  placeholder: const Text('Last Name'),
                  controller: lastName,
                  validator: (value) {
                    final error = InputValidation.validateLastName(value);
                    if (error != null) {
                      return error;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
