import 'package:connectobia/src/shared/data/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FirstMessage extends StatelessWidget {
  final String name;
  const FirstMessage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AssetsPath.message,
            height: 150,
            width: 150,
          ),
          SizedBox(height: 16),
          Text(
            'Invite ${name.split(' ')[0].toLowerCase()} chat with one message',
            style: TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'You\'ll be able to send additional messages once your request has been accepted.',
            style: TextStyle(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
