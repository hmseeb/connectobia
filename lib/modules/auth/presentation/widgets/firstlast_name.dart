import 'package:connectobia/modules/auth/data/respository/input_validation.dart';
import 'package:connectobia/modules/dashboard/presentation/views/user_setting.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A form that allows a user to sign up.
/// [SignupForm] contains fields for first name, last name, email, and password.
///
/// {@category Forms}
class FirstLastName extends StatelessWidget {
  final TextEditingController firstName, lastName;
  final bool showLabels;
  const FirstLastName({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.showLabels,
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
                showLabels == true
                    ? const LabeledTextField('First Name')
                    : const SizedBox.shrink(),
                ShadInputFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  placeholder: const Text('First Name'),
                  controller: firstName,
                  keyboardType: TextInputType.name,
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
                showLabels == true
                    ? const LabeledTextField('Last Name')
                    : const SizedBox.shrink(),
                ShadInputFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  placeholder: const Text('Last Name'),
                  controller: lastName,
                  keyboardType: TextInputType.name,
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
