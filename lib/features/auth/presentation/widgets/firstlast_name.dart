import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FirstLastName extends StatelessWidget {
  final TextEditingController firstName, lastName;
  const FirstLastName({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          // optional flex property if flex is 1 because the default flex is 1
          child: ShadInputFormField(
            placeholder: const Text('First Name*'),
            controller: firstName,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          // optional flex property if flex is 1 because the default flex is 1
          child: ShadInputFormField(
            placeholder: const Text('Last Name*'),
            controller: lastName,
          ),
        ),
      ],
    );
  }
}
