import 'package:connectobia/features/auth/presentation/screens/brand_agency_screen.dart';
import 'package:connectobia/features/auth/presentation/screens/creator_screen.dart';
import 'package:connectobia/features/auth/presentation/screens/login_screen.dart';
import 'package:connectobia/features/auth/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

class GenerateRoutes {
  static onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
              const WelcomeScreen(),
          transitionDuration: const Duration(milliseconds: 600),
        );
      case '/login':
        return PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
              const SigninScreen(),
          transitionDuration: const Duration(milliseconds: 600),
        );
      case '/brand-agency-signup':
        return PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
              const BrandAgencyScreen(),
          transitionDuration: const Duration(milliseconds: 600),
        );
      case '/creator-signup':
        return PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
              const CreatorScreen(),
          transitionDuration: const Duration(milliseconds: 600),
        );

      default:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
    }
  }
}
