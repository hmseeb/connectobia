import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreatorScreen extends StatelessWidget {
  const CreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SizedBox(
        width: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Collaborate with the best brands',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Row(
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
            ),
            const ShadInput(
              placeholder: Text('Email'),
              prefix: Icon(Icons.email_outlined),
            ),
            const ShadInput(
              placeholder: Text('Password'),
              prefix: Icon(Icons.lock_outline),
              suffix: Icon(Icons.visibility_off_outlined),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 350,
              child: ShadButton(
                child: const Text('Create account'),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Don\'t have an account? ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    'Sign up',
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
    ));
  }
}
