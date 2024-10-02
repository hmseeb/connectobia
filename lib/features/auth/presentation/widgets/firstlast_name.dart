import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FirstLastName extends StatelessWidget {
  const FirstLastName({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          // optional flex property if flex is 1 because the default flex is 1
          child: ShadInput(
            placeholder: Text('First name'),
            prefix: Icon(Icons.person_outline),
          ),
        ),
        SizedBox(width: 10.0),
        Expanded(
          // optional flex property if flex is 1 because the default flex is 1
          child: ShadInput(
            placeholder: Text('Last name'),
            prefix: Icon(Icons.person_outline),
          ),
        ),
      ],
    );
  }
}
