/// This file defines the route generation logic for the Connectobia application.
/// It includes the `GenerateRoutes` class which contains a static method to handle
/// route generation based on the route name provided in the `RouteSettings`.
///
/// The routes are defined as follows:
/// - `/`: Displays the [SplashScreen](package:connectobia/globals/screens/splash_screen.dart).
/// - `/welcome`: Displays the [WelcomeScreen](package:connectobia/modules/auth/presentation/screens/welcome_screen.dart) with arguments.
/// - `/signin`: Displays the [SigninScreen](package:connectobia/modules/auth/presentation/screens/login_screen.dart).
/// - `/brand-agency-signup`: Displays the [BrandAgencyScreen](package:connectobia/modules/auth/presentation/screens/brand_agency_screen.dart).
/// - `/creator-signup`: Displays the [CreatorScreen](package:connectobia/modules/auth/presentation/screens/creator_screen.dart).
/// - `/home`: Displays the [HomeScreen](package:connectobia/modules/Home/presentation/screens/home_screen.dart).
///
/// If an unknown route is provided, the [SplashScreen](package:connectobia/globals/screens/splash_screen.dart) is displayed by default.
library;

import 'package:connectobia/src/app.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/brand_agency_screen.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/creator_screen.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/login_screen.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/verify_email_screen.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/welcome_screen.dart';
import 'package:connectobia/src/modules/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

/// A class responsible for generating routes for the application.
class GenerateRoutes {
  /// Generates a route based on the given [RouteSettings].
  ///
  /// The method uses a switch-case to determine which screen to display
  /// based on the route name provided in [settings.name].
  static onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return PageRouteBuilder(
            pageBuilder: (_, animation, secondaryAnimation) =>
                const Connectobia());
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
      case '/verify-email':
        final args = settings.arguments as Map<String, dynamic>;
        return _buildPageRoute(VerifyEmail(
          email: args['email'],
        ));
      case '/brand-agency-signup':
        return _buildPageRoute(const BrandAgencyScreen());
      case '/creator-signup':
        return _buildPageRoute(const CreatorScreen());
      case '/home':
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, animation, secondaryAnimation) => const HomeScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const Connectobia());
    }
  }

  /// A helper method to build page routes with a consistent transition.
  ///
  /// This method creates a [PageRouteBuilder] with a fade transition and a slight
  /// upward slide for a smooth feel.
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
