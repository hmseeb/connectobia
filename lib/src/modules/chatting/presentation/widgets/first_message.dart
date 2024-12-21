import 'package:connectobia/src/shared/data/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FirstMessage extends StatelessWidget {
  const FirstMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AssetsPath.message,
            height: 200,
            width: 200,
          ),
          SizedBox(height: 16),
          Text(
            'Send message request',
            style: TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
