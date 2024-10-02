import 'package:connectobia/features/auth/presentation/widgets/auth_flow.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: SizedBox(
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Log in to your account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 350,
                  child: ShadButton(
                    child: const Text('Sign in'),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 40),
                AuthFlow(
                  title: 'Don\'t have an account? ',
                  buttonText: 'Sign up',
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
