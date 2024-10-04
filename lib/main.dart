import 'package:connectobia/features/auth/application/signup_bloc/signup_bloc_bloc.dart';
import 'package:connectobia/globals/screens/splash_screen.dart';
import 'package:connectobia/routes.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:connectobia/theme/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkMode;

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
          BlocProvider(create: (context) => SignupBloc()), // AuthBloc
          BlocProvider(create: (context) => ThemeCubit()), // AuthBloc
        ],
        child: BlocConsumer<ThemeCubit, ThemeState>(
          listener: (context, state) {
            if (state is DarkTheme) {
              isDarkMode = true;
            } else if (state is LightTheme) {
              isDarkMode = false;
            }
          },
          builder: (context, state) {
            return ShadApp(
              debugShowCheckedModeBanner: false,
              onGenerateRoute: (settings) =>
                  GenerateRoutes.onGenerateRoute(settings),
              themeMode: state is DarkTheme ? ThemeMode.dark : ThemeMode.light,
              theme: ShadThemeData(
                brightness:
                    state is DarkTheme ? Brightness.dark : Brightness.light,
                // colorScheme: state is DarkTheme
                //     ? const ShadSlateColorScheme.dark(
                //         primary: Pellet.kPrimary,
                //         secondary: Pellet.kSecondary,
                //         background: Pellet.kBackground,
                //         foreground: Pellet.kForeground,
                //         secondaryForeground: Colors.black,
                //       ),
                colorScheme: state is DarkTheme
                    ? const ShadSlateColorScheme.dark(
                        primary: Pellet.kPrimary,
                        secondary: Pellet.kSecondary,
                        foreground: Pellet.kBackground,
                        background: Pellet.kForeground,
                      )
                    : const ShadSlateColorScheme.light(
                        primary: Pellet.kPrimary,
                        secondary: Pellet.kSecondary,
                        foreground: Pellet.kForeground,
                        background: Pellet.kBackground,
                      ),
              ),
              home: const SplashScreen(),
              title: 'Connectobia',
            );
          },
        ),
      ),
    );
  }
}
