import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/theme/shad_themedata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'modules/auth/application/auth/auth_bloc.dart';
import 'routes.dart';
import 'shared/application/animation/animation_cubit.dart';
import 'shared/application/theme/theme_bloc.dart';
import 'shared/data/constants/assets.dart';
import 'theme/colors.dart';

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
  late bool isDarkMode;
  late RiveAnimationController _riveAnimationController;
  AuthState authState = AuthInitial();

  dynamic user;

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
            title: 'createCampaign',
            initialRoute: createCampaign,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: (settings) =>
                GenerateRoutes.onGenerateRoute(settings),
            themeMode: state is DarkTheme ? ThemeMode.dark : ThemeMode.light,
            theme: shadThemeData(state),
            home: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is BrandAuthenticated ||
                    state is InfluencerAuthenticated ||
                    state is Unauthenticated ||
                    state is Unverified ||
                    state is AuthError) {
                  handleNavigation(state: state, context: context);
                }
                debugPrint(state.runtimeType.toString());
                authState = state;
              },
              child: BlocListener<AnimationCubit, AnimationState>(
                listener: (context, state) {
                  if (state is AnimationStopped) {}
                },
                child: Scaffold(
                  backgroundColor: ShadColors.primary,
                  body: RiveAnimation.asset(
                    AssetsPath.splash,
                    controllers: [_riveAnimationController],
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
    _riveAnimationController.dispose();
    _riveAnimationController.isActiveChanged.removeListener(() {});
    super.dispose();
  }

  /// Checks the authentication status of the user.
  ///
  /// If the user is authenticated, it fetches the user details and verifies the email.
  void handleNavigation(
      {required AuthState state, required BuildContext context}) async {
    if (state is InfluencerAuthenticated) {
      if (state.user.onboarded) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          influencerDashboard,
          (route) => false,
          arguments: {'user': state.user},
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          influencerOnboarding,
          (route) => false,
          arguments: {'user': state.user},
        );
      }
    } else if (state is BrandAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        brandDashboard,
        (route) => false,
        arguments: {'user': state.user},
      );
    } else if (state is Unauthenticated) {
      Navigator.pushReplacementNamed(
        context,
        welcomeScreen,
      );
    } else if (state is Unverified) {
      Navigator.pushReplacementNamed(
        context,
        verifyEmailScreen,
        arguments: {
          'email': state.email,
        },
      );
    } else if (state is AuthError) {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: Text(state.message),
        ),
      );
      Navigator.pushReplacementNamed(
        context,
        welcomeScreen,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode; // Initialize isDarkMode with widget's value
    _riveAnimationController = SimpleAnimation(
      'Timeline 1',
    );
    _riveAnimationController.isActiveChanged.addListener(() {
      if (!_riveAnimationController.isActive) {
        context.read<AnimationCubit>().animationStopped();
      }
    });
  }
}
