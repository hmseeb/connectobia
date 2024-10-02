import 'package:connectobia/features/auth/presentation/views/privacy_policy.dart';
import 'package:connectobia/features/auth/presentation/widgets/firstlast_name.dart';
import 'package:connectobia/features/auth/presentation/widgets/heading_text.dart';
import 'package:connectobia/theme/buttons.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreatorScreen extends StatelessWidget {
  const CreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const HeadingText(
                  'Collaborate with the best brands',
                ),
                const SizedBox(height: 10),
                const FirstLastName(),
                const ShadInput(
                  placeholder: Text('Email'),
                  prefix: Icon(Icons.email_outlined),
                ),
                const ShadInput(
                  placeholder: Text('Password'),
                  prefix: Icon(Icons.lock_outline),
                  suffix: Icon(Icons.visibility_off_outlined),
                ),
                const SizedBox(height: 10),
                // by signing up, you agree to our terms of service and privacy policy
                const PrivacyPolicy(),
                const SizedBox(height: 10),
                PrimaryAuthButton(
                  text: 'Create account',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
