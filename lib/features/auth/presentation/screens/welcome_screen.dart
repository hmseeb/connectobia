import 'package:connectobia/features/auth/presentation/views/connection_icon.dart';
import 'package:connectobia/features/auth/presentation/widgets/auth_flow.dart';
import 'package:connectobia/features/auth/presentation/widgets/heading_text.dart';
import 'package:connectobia/features/auth/presentation/widgets/signup_card.dart';
import 'package:connectobia/features/auth/presentation/widgets/tagline.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeadingText('Welcome to '),
                ConnectionIcon(),
                HeadingText('bia'),
              ],
            ),
            const Tagline('where brands and influencers meet'),
            const SizedBox(height: 30),
            SignupCard(
              title: 'Brand or Agency',
              description: 'I want to grow my business',
              onPressed: () {
                Navigator.pushNamed(context, '/brand-agency-signup');
              },
            ),
            const SizedBox(height: 10),

            SignupCard(
              title: 'Influencer',
              description: 'I want to monetize my content',
              onPressed: () {
                Navigator.pushNamed(context, '/creator-signup');
              },
            ),
            const SizedBox(height: 30),
            // Already have an account? Sign in
            AuthFlow(
              title: 'Already have an account? ',
              buttonText: 'Sign in',
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
            ),
          ],
        ),
      ),
    );
  }
}
