import 'package:flutter/material.dart';

class SubHeading extends StatelessWidget {
  final String text;
  const SubHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
      ),
      textAlign: TextAlign.center,
    );
  }
}
