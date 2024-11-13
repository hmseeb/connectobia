import 'package:connectobia/db/db.dart';
import 'package:connectobia/globals/constants/navigation_service.dart';
import 'package:connectobia/globals/constants/path.dart';
import 'package:connectobia/modules/auth/application/email_verification/email_verification_bloc.dart';
import 'package:connectobia/modules/auth/application/login/login_bloc.dart';
import 'package:connectobia/modules/auth/application/signup/signup_bloc.dart';
import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:connectobia/modules/auth/presentation/screens/verify_email_screen.dart';
import 'package:connectobia/modules/auth/presentation/screens/welcome_screen.dart';
import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/modules/dashboard/application/edit_profile/edit_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/presentation/screens/brand_dashboard.dart';
import 'package:connectobia/routes.dart';
import 'package:connectobia/theme/bloc/theme_bloc.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:connectobia/theme/shad_themedata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The main widget for the Connectobia application.
///
/// The widget initializes the application and checks the authentication status of the user.
/// It also initializes the theme based on the user's preferences or system settings.
class Connectobia extends StatefulWidget {
  final bool isDarkMode;

  const Connectobia({super.key, required this.isDarkMode});

  @override
  State<Connectobia> createState() => ConnectobiaState();
}

/// The state class for the [Connectobia] widget.
class ConnectobiaState extends State<Connectobia> {
  late bool isAuthenticated;
  late bool isDarkMode;
  User? user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => ThemeBloc()..add(ThemeChanged(isDarkMode))),
          BlocProvider(create: (context) => LoginBloc()),
          BlocProvider(create: (context) => SignupBloc()),
          BlocProvider(create: (context) => EmailVerificationBloc()),
          BlocProvider(create: (context) => BrandDashboardBloc()),
          BlocProvider(create: (context) => EditProfileBloc()),
        ],
        child: BlocConsumer<ThemeBloc, ThemeState>(
          listener: (context, state) {},
          builder: (context, state) {
            return ShadApp(
              title: 'Connectobia',
              initialRoute: '/',
              navigatorKey: NavigationService.navigatorKey,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: (settings) =>
                  GenerateRoutes.onGenerateRoute(settings),
              // themeMode: state is DarkTheme ? ThemeMode.dark : ThemeMode.light,
              theme: shadThemeData(state),
              home: SizedBox(
                child: SplashScreen.navigate(
                  backgroundColor: ShadColors.primary,
                  name: AssetsPath.splash,
                  next: (context) {
                    if (user == null) {
                      PocketBaseSingleton.instance.then((pb) {
                        if (!pb.authStore.isValid) pb.authStore.clear();
                      });
                      return const WelcomeScreen();
                    } else {
                      if (user!.verified) {
                        return BrandDashboard(user: user!);
                      } else {
                        return VerifyEmail(email: user!.email);
                      }
                    }
                  },
                  until: () async {},
                  startAnimation: 'Timeline 1',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Checks the authentication status of the user.
  ///
  /// If the user is authenticated, it fetches the user details and verifies the email.
  Future<void> checkAuth() async {
    PocketBase pocketBase = await PocketBaseSingleton.instance;

    isAuthenticated = pocketBase.authStore.isValid;
    if (isAuthenticated) {
      try {
        user = await AuthRepo.getUser();
        if (!user!.verified) {
          await AuthRepo.verifyEmail(user!.email);
        }
      } catch (e) {
        if (!pocketBase.authStore.isValid) pocketBase.authStore.clear();
        debugPrint(e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode; // Initialize isDarkMode with widget's value
    checkAuth();
  }
}
