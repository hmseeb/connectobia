import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to ',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Transform(
                  transform: Matrix4.rotationZ(0.1),
                  child: const Icon(
                    Icons.link,
                    color: Colors.redAccent,
                  ),
                ),
                const Text(
                  'bia',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'where brands and agencies meet creators'.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/brand-agency-signup');
              },
              child: SizedBox(
                width: 350,
                child: ShadCard(
                  title: const Text('Brand or Agency'),
                  description:
                      const Text('I want to promote my brand or agency'),
                  backgroundColor: const Color(0xFFF2F0EA),
                  radius: BorderRadius.circular(16),
                  trailing: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/creator-signup');
              },
              child: SizedBox(
                width: 350,
                child: ShadCard(
                  title: const Text('Creator'),
                  description: const Text('I want to monetize my social media'),
                  backgroundColor: const Color(0xFFF2F0EA),
                  radius: BorderRadius.circular(16),
                  trailing: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Already have an account? Sign in
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
