import 'package:connectobia/features/auth/presentation/screens/brand_agency_screen.dart';
import 'package:connectobia/features/auth/presentation/screens/creator_screen.dart';
import 'package:connectobia/features/auth/presentation/screens/login_screen.dart';
import 'package:connectobia/features/auth/presentation/screens/welcome_screen.dart';
import 'package:connectobia/globals/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class GenerateRoutes {
  static onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return PageRouteBuilder(
            pageBuilder: (_, animation, secondaryAnimation) =>
                const SplashScreen());
      case '/welcome':
        final args = settings.arguments as Map<String, dynamic>;
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, animation, secondaryAnimation) => WelcomeScreen(
            isDarkMode: args['isDarkMode'],
          ),
        );
      case '/signin':
        return _buildPageRoute(const SigninScreen());
      case '/brand-agency-signup':
        return _buildPageRoute(const BrandAgencyScreen());
      case '/creator-signup':
        return _buildPageRoute(const CreatorScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }

  // A helper method to build page routes with a consistent transition
  static PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(
          milliseconds: 400), // Quick but smooth transition duration
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define a fade transition with a slight upward slide for a smooth feel
        const begin = Offset(0.0, 0.1); // Start a bit lower
        const end = Offset.zero; // End at normal position
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween =
            Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: fadeTween.animate(animation),
          child: SlideTransition(
            position: tween.animate(animation),
            child: child,
          ),
        );
      },
    );
  }
}
