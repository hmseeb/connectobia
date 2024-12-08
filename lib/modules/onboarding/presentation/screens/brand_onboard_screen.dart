import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/domain/model/brand.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
