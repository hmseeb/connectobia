import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BrandAgencyScreen extends StatelessWidget {
  const BrandAgencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    late final accountTypes = {
      'brand': 'Brand',
      'agency': 'Agency',
    };
    return Scaffold(
        body: Center(
      child: SizedBox(
        width: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Match with Creators',
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
              placeholder: Text('Business Email'),
              prefix: Icon(Icons.email_outlined),
            ),
            const ShadInput(
              placeholder: Text('Company Website'),
              // globe icon prefix
              prefix: Icon(Icons.public_outlined),
            ),
            const ShadInput(
              placeholder: Text('Password'),
              prefix: Icon(Icons.lock_outline),
              suffix: Icon(Icons.visibility_off_outlined),
            ),
            SizedBox(
              width: 350,
              child: ShadSelect<String>(
                placeholder: const Text('Select account type'),
                options: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(32, 6, 6, 6),
                  ),
                  ...accountTypes.entries.map(
                      (e) => ShadOption(value: e.key, child: Text(e.value))),
                ],
                selectedOptionBuilder: (context, value) =>
                    Text(accountTypes[value]!),
                onChanged: print,
              ),
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
