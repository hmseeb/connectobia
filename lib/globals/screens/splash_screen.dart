import 'package:connectobia/db/pb.dart';
import 'package:connectobia/db/shared_prefs.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:connectobia/theme/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late bool isDarkMode;
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Pellet.kSecondary,
      body: Center(
        child: Hero(
          tag: 'logo',
          child: Icon(
            Icons.link,
            color: Colors.white,
            size: 100,
          ),
        ),
      ),
    );
  }

  Future<bool> checkAuth() async {
    PocketBase pocketBase = await PocketBaseSingleton.instance;
    return pocketBase.authStore.isValid;
  }

  @override
  void initState() {
    _manageNextScreen();
    _loadDarkModePreference();
    super.initState();
  }

  // Method to load the dark mode preference from Shared Preferences
  Future<void> _loadDarkModePreference() async {
    final prefs = await SharedPrefs.instance;
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool isDarkTheme = brightness == Brightness.dark;
    isDarkMode = prefs.getBool('darkMode') ?? isDarkTheme; // Default is false
    if (mounted) {
      ThemeCubit themeCubit = BlocProvider.of<ThemeCubit>(context);
      themeCubit.toggleTheme(isDarkMode);
    }
  }

  void _manageNextScreen() {
    // TODO: Implement dynamic timer
    Future.delayed(const Duration(seconds: 2), () async {
      if (await checkAuth()) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/welcome',
              arguments: {'isDarkMode': isDarkMode});
        }
      }
    });
  }
}
