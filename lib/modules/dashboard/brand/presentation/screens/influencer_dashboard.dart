import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/domain/model/influencer.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InfluencerDashboard extends StatelessWidget {
  final Influencer influencer;
  const InfluencerDashboard({super.key, required this.influencer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Influencer Dashboard'),
            const SizedBox(height: 20),
            // logout button
            ShadButton.destructive(
              onPressed: () async {
                AuthRepo.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/welcomeScreen',
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
