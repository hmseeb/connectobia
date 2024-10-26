import 'package:connectobia/src/db/pb.dart';
import 'package:connectobia/src/db/shared_prefs.dart';
import 'package:connectobia/src/globals/constants/navigation_service.dart';
import 'package:connectobia/src/modules/auth/application/login/login_bloc.dart';
import 'package:connectobia/src/modules/auth/application/signup/signup_bloc.dart';
import 'package:connectobia/src/modules/auth/data/respository/auth_repo.dart';
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
  late bool isAuthenticated;
  late String accountType;
  ThemeCubit themeCubit = ThemeCubit();

  @override
  Widget build(BuildContext context) {
    debugPrint('Building Connectobia');
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
          BlocProvider(create: (context) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
          return ShadApp(
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
                    return isAuthenticated
                        ? const HomeScreen()
                        : WelcomeScreen(isDarkMode: state is DarkTheme);
                  },
                  until: () async {
                    _initializeTheme(context);
                  },
                  startAnimation: 'Timeline 1',
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> checkAuth() async {
    PocketBase pocketBase = await PocketBaseSingleton.instance;
    isAuthenticated = pocketBase.authStore.isValid;
    if (isAuthenticated) {
      accountType = await AuthRepo.getAccountType();
    }
  }

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> _initializeTheme(BuildContext context) async {
    final prefs = await SharedPrefs.instance;
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? (brightness == Brightness.dark);
    });
    themeCubit.toggleTheme(isDarkMode);
  }
}
