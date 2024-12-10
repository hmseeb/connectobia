import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../auth/data/respository/auth_repo.dart';
import '../../../auth/domain/model/brand.dart';

class BrandOnboarding extends StatelessWidget {
  final Brand user;
  const BrandOnboarding({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ShadButton(
          onPressed: () async {
            await AuthRepo.logout();
          },
          child: Text('Brand Onboarding (logout button)'),
        ),
      ),
    );
  }
}
