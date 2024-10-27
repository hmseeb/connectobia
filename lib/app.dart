import 'package:connectobia/db/db.dart';
import 'package:connectobia/db/shared_prefs.dart';
import 'package:connectobia/globals/constants/navigation_service.dart';
import 'package:connectobia/modules/auth/application/email_verification/email_verification_bloc.dart';
import 'package:connectobia/modules/auth/application/login/login_bloc.dart';
import 'package:connectobia/modules/auth/application/signup/signup_bloc.dart';
import 'package:connectobia/modules/auth/application/subscription/bloc/subscription_bloc.dart';
import 'package:connectobia/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:connectobia/modules/auth/presentation/screens/verify_email_screen.dart';
import 'package:connectobia/modules/auth/presentation/screens/welcome_screen.dart';
import 'package:connectobia/modules/home/presentation/screens/home_screen.dart';
import 'package:connectobia/routes.dart';
import 'package:connectobia/theme/cubit/theme_cubit.dart';
import 'package:connectobia/theme/shad_themedata.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The main widget for the Connectobia application.
class Connectobia extends StatefulWidget {
  const Connectobia({super.key});

  @override
  State<Connectobia> createState() => ConnectobiaState();
}

/// The state class for the [Connectobia] widget.
class ConnectobiaState extends State<Connectobia> {
  late bool isDarkMode;
  User? user;
  late final bool isAuthenticated;
  ThemeCubit themeCubit = ThemeCubit();

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
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(create: (context) => LoginBloc()),
          BlocProvider(create: (context) => SignupBloc()),
          BlocProvider(create: (context) => SubscriptionBloc()),
          BlocProvider(create: (context) => EmailVerificationBloc()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
          BlocProvider.of<SubscriptionBloc>(context).add(UserInitialEvent());
          return BlocListener<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) {},
            child: ShadApp(
              title: 'Connectobia',
              initialRoute: '/',
              navigatorKey: NavigationService.navigatorKey,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: (settings) =>
                  GenerateRoutes.onGenerateRoute(settings),
              themeMode: state is DarkTheme ? ThemeMode.dark : ThemeMode.light,
              theme: shadThemeData(state is DarkTheme),
              home: Scaffold(
                body: Hero(
                  tag: 'splash',
                  child: SplashScreen.navigate(
                    name: state is DarkTheme
                        ? 'assets/animations/dark.riv'
                        : 'assets/animations/light.riv',
                    next: (context) {
                      if (isAuthenticated) {
                        if (user == null) {
                          PocketBaseSingleton.instance.then((pb) {
                            pb.authStore.clear();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/welcome',
                                (route) => false,
                                arguments: {'isDarkMode': isDarkMode},
                              );
                            }
                          });
                        }
                        if (user!.verified) {
                          return const HomeScreen();
                        } else {
                          return VerifyEmail(
                            email: user!.email,
                          );
                        }
                      } else {
                        return WelcomeScreen(
                          isDarkMode: isDarkMode,
                        );
                      }
                    },
                    until: () async {
                      _initializeTheme(context);
                    },
                    startAnimation: 'Timeline 1',
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Checks the authentication status of the user.
  ///
  /// If the user is authenticated, it fetches the user details and verifies the email.
  /// If the user is not authenticated, it clears the authentication store and navigates
  /// to the welcome screen.
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
        pocketBase.authStore.clear();
        isAuthenticated = false;
        if (mounted) {
          ShadThemeData theme = ShadTheme.of(context);
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/welcome',
            (route) => false,
            arguments: {'isDarkMode': theme.brightness == Brightness.dark},
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (context.mounted) {
      checkAuth();
    }
  }

  /// Initializes the theme based on the user's preferences or system settings.
  ///
  /// It retrieves the theme preference from shared preferences and toggles the theme accordingly.
  Future<void> _initializeTheme(BuildContext context) async {
    final prefs = await SharedPrefs.instance;
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode = prefs.getBool('darkMode') ?? (brightness == Brightness.dark);
    themeCubit.toggleTheme(isDarkMode);
  }
}
