import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../theme/colors.dart';

/// A widget that displays the privacy policy
///
/// This widget is used to display the privacy policy of the application. It is
/// used to inform the user about the terms of service and privacy policy of the
/// application.
///
/// {@category Widgets}
class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text(
          'By creating an account, you agree to our ',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        GestureDetector(
          onTap: () {
            final Uri url = Uri.parse(
                'https://github.com/hmseeb/connectobia/blob/main/tos.md');
            launchUrl(url);
          },
          child: Text(
            'terms of service ',
            style: TextStyle(
              fontSize: 12,
              color: ShadColors.primary,
            ),
          ),
        ),
        Text(
          'and ',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        GestureDetector(
          onTap: () {
            final Uri url = Uri.parse(
                'https://github.com/hmseeb/connectobia/blob/main/privacy_policy.md');
            launchUrl(url);
          },
          child: Text(
            'privacy policy',
            style: TextStyle(
              fontSize: 12,
              color: ShadColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
