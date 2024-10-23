import 'package:connectobia/src/db/pb.dart';
import 'package:connectobia/src/db/shared_prefs.dart';
import 'package:connectobia/src/modules/auth/application/login/login_bloc.dart';
import 'package:connectobia/src/modules/auth/application/signup/signup_bloc.dart';
import 'package:connectobia/src/modules/auth/presentation/screens/welcome_screen.dart';
import 'package:connectobia/src/modules/home/presentation/screens/home_screen.dart';
import 'package:connectobia/src/routes.dart';
import 'package:connectobia/src/theme/cubit/theme_cubit.dart';
import 'package:connectobia/src/theme/shad_themedata.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Connectobia extends StatefulWidget {
  const Connectobia({super.key});

  @override
  State<Connectobia> createState() => ConnectobiaState();
}

class ConnectobiaState extends State<Connectobia> {
  late bool isDarkMode;
  bool isAuthenticated = false;

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
          BlocProvider(create: (context) => LoginBloc()),
          BlocProvider(create: (context) => SignupBloc()),
          BlocProvider(create: (context) => ThemeCubit()), // ThemeCubit
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
          return FutureBuilder(
            future: _initializeTheme(context),
            builder: (context, snapshot) => snapshot.connectionState !=
                    ConnectionState.done
                ? const Center(child: CircularProgressIndicator())
                : ShadApp(
                    debugShowCheckedModeBanner: false,
                    onGenerateRoute: (settings) =>
                        GenerateRoutes.onGenerateRoute(settings),
                    themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                    theme: shadThemeData(isDarkMode),
                    home: Scaffold(
                      body: SplashScreen.navigate(
                        name: isDarkMode
                            ? 'assets/animations/dark.riv'
                            : 'assets/animations/light.riv',
                        next: (context) {
                          return isAuthenticated
                              ? const HomeScreen()
                              : WelcomeScreen(isDarkMode: isDarkMode);
                        },
                        until: () async {
                          isAuthenticated = await checkAuth();
                        },
                        startAnimation: 'Timeline 1',
                      ),
                    )),
          );
        }),
      ),
    );
  }

  Future<bool> checkAuth() async {
    PocketBase pocketBase = await PocketBaseSingleton.instance;
    return pocketBase.authStore.isValid;
  }

  Future<void> _initializeTheme(BuildContext context) async {
    isDarkMode = await _loadDarkModePreference();
  }

  Future<bool> _loadDarkModePreference() async {
    final prefs = await SharedPrefs.instance;
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool isDarkTheme = brightness == Brightness.dark;
    return prefs.getBool('darkMode') ?? isDarkTheme; // Default to system theme
  }
}
