import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A card that allows a user to sign up.
/// [SignupCard] contains a title, description, and a button to sign up.
///
/// {@category Widgets}
class SignupCard extends StatelessWidget {
  final String title;
  final String description;
  final void Function() onPressed;
  const SignupCard({
    super.key,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 400,
        child: ShadCard(
          title: Text(title),
          description: Text(description),
          radius: BorderRadius.circular(16),
          trailing: IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.arrow_forward),
          ),
        ),
      ),
    );
  }
}
