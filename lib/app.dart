import 'package:connectobia/common/constants/navigation_service.dart';
import 'package:connectobia/common/constants/path.dart';
import 'package:connectobia/modules/auth/application/bloc/auth_bloc.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:connectobia/modules/dashboard/application/animation/animation_cubit.dart';
import 'package:connectobia/routes.dart';
import 'package:connectobia/theme/bloc/theme_bloc.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:connectobia/theme/shad_themedata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
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
  late RiveAnimationController _riveAnimationcontroller;
  AuthState currentState = AuthInitial();
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
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ShadApp(
            title: 'Connectobia',
            initialRoute: '/',
            navigatorKey: NavigationService.navigatorKey,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: (settings) =>
                GenerateRoutes.onGenerateRoute(settings),
            themeMode: state is DarkTheme ? ThemeMode.dark : ThemeMode.light,
            theme: shadThemeData(state),
            home: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                currentState = state;
              },
              child: BlocListener<AnimationCubit, AnimationState>(
                listener: (context, state) {
                  if (state is AnimationStopped) {
                    handleNavigation(state: currentState, context: context);
                  }
                },
                child: Scaffold(
                  backgroundColor: ShadColors.primary,
                  body: RiveAnimation.asset(
                    AssetsPath.splash,
                    controllers: [_riveAnimationcontroller],
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _riveAnimationcontroller.dispose();
    _riveAnimationcontroller.isActiveChanged.removeListener(() {});
    super.dispose();
  }

  /// Checks the authentication status of the user.
  ///
  /// If the user is authenticated, it fetches the user details and verifies the email.
  void handleNavigation(
      {required AuthState state, required BuildContext context}) {
    if (state is Authenticated) {
      Navigator.pushReplacementNamed(
        context,
        '/brandDashboard',
        arguments: {
          'user': state.user,
        },
      );
    } else if (state is Unauthenticated) {
      Navigator.pushReplacementNamed(
        context,
        '/welcomeScreen',
      );
    } else if (state is Unverified) {
      Navigator.pushReplacementNamed(
        context,
        '/verifyEmailScreen',
        arguments: {
          'email': state.email,
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode; // Initialize isDarkMode with widget's value
    _riveAnimationcontroller = SimpleAnimation(
      'Timeline 1',
    );
    _riveAnimationcontroller.isActiveChanged.addListener(() {
      if (!_riveAnimationcontroller.isActive) {
        context.read<AnimationCubit>().animationStopped();
      }
    });
  }
}
