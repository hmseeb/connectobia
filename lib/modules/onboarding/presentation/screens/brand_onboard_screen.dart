import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:flutter/material.dart';

class BrandOnboarding extends StatelessWidget {
  final User user;
  const BrandOnboarding({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Brand Onboarding'),
      ),
    );
  }
}
