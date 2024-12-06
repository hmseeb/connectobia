/// This file defines the route generation logic for the Connectobia application.
/// It includes the `GenerateRoutes` class which contains a static method to handle
/// route generation based on the route name provided in the `RouteSettings`.
///
/// The routes are defined as follows:
/// - `/`: Displays the [SplashScreen](package:connectobia/globals/screens/splash_screen.dart).
/// - `/welcomeScreen`: Displays the [WelcomeScreen](package:connectobia/modules/auth/presentation/screens/welcomeScreen_screen.dart) with arguments.
/// - `/signinScreen`: Displays the [SigninScreen](package:connectobia/modules/auth/presentation/screens/login_screen.dart).
/// - `/brandSignupScreen`: Displays the [BrandAgencyScreen](package:connectobia/modules/auth/presentation/screens/brand_agency_screen.dart).
/// - `/creatorSignupScreen`: Displays the [CreatorScreen](package:connectobia/modules/auth/presentation/screens/creator_screen.dart).
/// - `/homeScreen`: Displays the [HomeScreen](package:connectobia/modules/homeScreen/presentation/screens/homeScreen_screen.dart).
///
/// If an unknown route is provided, the [SplashScreen](package:connectobia/globals/screens/splash_screen.dart) is displayed by default.
library;

import 'package:connectobia/app.dart';
import 'package:connectobia/modules/auth/presentation/screens/brand_screen.dart';
import 'package:connectobia/modules/auth/presentation/screens/creator_screen.dart';
import 'package:connectobia/modules/auth/presentation/screens/login_screen.dart';
import 'package:connectobia/modules/auth/presentation/screens/verify_email_screen.dart';
import 'package:connectobia/modules/auth/presentation/screens/welcome_screen.dart';
import 'package:connectobia/modules/dashboard/presentation/screens/brand_dashboard.dart';
import 'package:connectobia/modules/dashboard/presentation/screens/influencer_profile.dart';
import 'package:connectobia/modules/onboarding/presentation/screens/brand_onboard_screen.dart';
import 'package:connectobia/modules/onboarding/presentation/screens/influencer_onboard_screen.dart';
import 'package:flutter/material.dart';

/// A class responsible for generating routes for the application.
///
/// The class contains a static method `onGenerateRoute` which generates
/// a route based on the provided [RouteSettings].
///
/// The method uses a switch-case to determine which screen to display
/// based on the route name provided in [settings.name].
///
/// {@category Routing}
class GenerateRoutes {
  /// Generates a route based on the given [RouteSettings].
  ///
  /// The method uses a switch-case to determine which screen to display
  /// based on the route name provided in [settings.name].
  static onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        final args = settings.arguments as Map<String, dynamic>;

        return PageRouteBuilder(
            pageBuilder: (_, animation, secondaryAnimation) => Connectobia(
                  isDarkMode: args['isDarkMode'],
                ));
      case '/welcomeScreen':
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, animation, secondaryAnimation) =>
              const WelcomeScreen(),
        );
      case '/signinScreen':
        return _buildPageRoute(const SigninScreen());
      case '/influencerOnboarding':
        final args = settings.arguments as Map<String, dynamic>;

        return _buildPageRoute(InfluencerOnboarding(
          user: args['user'],
        ));
      case '/brandOnboarding':
        final args = settings.arguments as Map<String, dynamic>;

        return _buildPageRoute(BrandOnboarding(
          user: args['user'],
        ));
      case '/influencerProfile':
        final args = settings.arguments as Map<String, dynamic>;
        return _buildPageRoute(InfluencerProfile(
          userId: args['userId'],
        ));
      case '/verifyEmailScreen':
        final args = settings.arguments as Map<String, dynamic>;
        return _buildPageRoute(VerifyEmail(
          email: args['email'],
        ));
      case '/brandSignupScreen':
        return _buildPageRoute(const BrandScreen());
      case '/brandDashboard':
        final args = settings.arguments as Map<String, dynamic>;
        return _buildPageRoute(BrandDashboard(
          user: args['user'],
        ));
      case '/creatorSignupScreen':
        return _buildPageRoute(const CreatorScreen());
      case '/homeScreen':
        final args = settings.arguments as Map<String, dynamic>;
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, animation, secondaryAnimation) => BrandDashboard(
            user: args['user'],
          ),
        );
      default:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => Connectobia(
                  isDarkMode: args['isDarkMode'],
                ));
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
