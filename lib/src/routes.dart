/// This file defines the route generation logic for the Connectobia application.
/// It includes the `GenerateRoutes` class which contains a static method to handle
/// route generation based on the route name provided in the `RouteSettings`.
///
/// The routes are defined as follows:
/// - `/`: Displays the [SplashScreen](package:connectobia/globals/screens/splash_screen.dart).
/// - `/welcomeScreen`: Displays the [WelcomeScreen](package:connectobia/modules/auth/presentation/screens/welcomeScreen_screen.dart) with arguments.
/// - `/LoginScreen`: Displays the [LoginScreen](package:connectobia/modules/auth/presentation/screens/login_screen.dart).
/// - `/brandSignupScreen`: Displays the [BrandAgencyScreen](package:connectobia/modules/auth/presentation/screens/brand_agency_screen.dart).
/// - `/InfluencerSignupScreen`: Displays the [InfluencerScreen](package:connectobia/modules/auth/presentation/screens/Influencer_screen.dart).
/// - `/homeScreen`: Displays the [HomeScreen](package:connectobia/modules/homeScreen/presentation/screens/homeScreen_screen.dart).
///
/// If an unknown route is provided, the [SplashScreen](package:connectobia/globals/screens/splash_screen.dart) is displayed by default.
library;

import 'package:connectobia/src/app.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/brand_signup_screen.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/influencer_signup_screen.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/login_screen.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/verify_email_screen.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/welcome_screen.dart';
import 'package:connectobia/src/modules/campaign/presentation/screens/campaign_screen.dart';
import 'package:connectobia/src/modules/campaign/presentation/screens/campaign_view.dart';
import 'package:connectobia/src/modules/campaign/presentation/screens/create_campaign.dart';
import 'package:connectobia/src/modules/chatting/presentation/screens/messages_screen.dart';
import 'package:connectobia/src/modules/dashboard/brand/presentation/screens/brand_dashboard.dart';
import 'package:connectobia/src/modules/dashboard/common/screens/user_profile.dart';
import 'package:connectobia/src/modules/dashboard/influencer/presentation/screens/influencer_dashboard.dart';
import 'package:connectobia/src/modules/edit_profile/presentation/screens/edit_profile_page.dart'
    as old_profile;
import 'package:connectobia/src/modules/notifications/presentation/screens/notifications_screen.dart';
import 'package:connectobia/src/modules/onboarding/presentation/screens/influencer_onboard_screen.dart';
import 'package:connectobia/src/modules/profile/presentation/screens/edit_profile_screen.dart'
    as new_profile;
import 'package:connectobia/src/modules/profile/presentation/screens/profile_screen.dart';
import 'package:connectobia/src/modules/profile/presentation/screens/review_screen.dart';
import 'package:connectobia/src/modules/wallet/presentation/screens/wallet_screen.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
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
// lib/routes.dart

class GenerateRoutes {
  /// Generates a route based on the given [RouteSettings].
  ///
  /// The method uses a switch-case to determine which screen to display
  /// based on the route name provided in [settings.name].
  static onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(Connectobia(
          isDarkMode: args['isDarkMode'],
        ));
      case welcomeScreen:
        return _buildAnimatedRoute(const WelcomeScreen());
      case loginScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(LoginScreen(
          accountType: args['accountType'],
        ));
      case influencerOnboarding:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(InfluencerOnboarding(
          user: args['user'],
        ));
      case profile:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(UserProfile(
          userId: args['profileId'],
          self: args['self'],
          profileType: args['profileType'],
        ));
      case verifyEmailScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildAnimatedRoute(VerifyEmail(
          email: args['email'],
        ));
      case brandSignupScreen:
        return _buildRoute(const BrandScreen());
      case brandDashboard:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildAnimatedRoute(BrandDashboard(
          user: args['user'],
        ));
      case influencerDashboard:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildAnimatedRoute(InfluencerDashboard(
          user: args['user'],
        ));
      case messagesScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(MessagesScreen(
          collectionId: args['collectionId'],
          userId: args['userId'],
          name: args['name'],
          avatar: args['avatar'],
          hasConnectedInstagram: args['hasConnectedInstagram'],
        ));
      case notificationsScreen:
        return _buildRoute(const NotificationsScreen());
      case influencerSignupScreen:
        return _buildRoute(const InfluencerScreen());

      case campaignsScreen:
        return _buildRoute(const CampaignScreen());

      case createCampaign:
        // Only brands can create campaigns
        final accountType = CollectionNameSingleton.instance;
        if (accountType == 'influencers') {
          // Redirect to campaigns screen if user is an influencer
          return _buildRoute(const CampaignScreen());
        }
        return _buildRoute(const CreateCampaignScreen());

      case campaignDetails:
        Map<String, dynamic> args = {};
        if (settings.arguments != null) {
          args = settings.arguments as Map<String, dynamic>;
        }
        return _buildRoute(CampaignDetailsPage(
          key: args['key'],
          campaignId: args['campaignId'],
          userType: args['userType'],
        ));

      case profileScreen:
        return _buildRoute(const ProfileScreen());

      case editProfileScreen:
        Map<String, dynamic> args = {};
        if (settings.arguments != null) {
          args = settings.arguments as Map<String, dynamic>;
        }
        return _buildRoute(new_profile.EditProfileScreen(
          key: args['key'],
          user: args['user'],
        ));

      case '/editProfile':
        return _buildRoute(const old_profile.EditProfileScreen());

      case reviewScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(ReviewScreen(
          contractId: args['contractId'],
        ));

      case walletScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(WalletScreen(
          userId: args['userId'],
        ));

      default:
        return _buildRoute(WelcomeScreen());
    }
  }

  /// A helper method to build page routes with a consistent transition.
  ///
  /// This method creates a [PageRouteBuilder] with a fade transition and a slight
  /// upward slide for a smooth feel.
  static PageRouteBuilder _buildAnimatedRoute(Widget page) {
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

  /// A helper method to build page routes with a consistent transition.
  /// This method creates a [MaterialPageRoute] with a fade transition for a smooth feel.
  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
