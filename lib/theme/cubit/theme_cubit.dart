import 'package:bloc/bloc.dart';
import 'package:connectobia/db/shared_prefs.dart';
import 'package:flutter/material.dart';

part 'theme_state.dart';

/// A cubit to manage the theme of the application
///
/// This cubit is used to manage the theme of the application. It is used to
/// toggle between the light and dark themes of the application.
///
/// {@category Theme}
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial());

  void toggleTheme(bool isDarkMode) async {
    final prefs = await SharedPrefs.instance;
    await prefs.setBool('darkMode', isDarkMode);
    debugPrint('Theme mode set to ${isDarkMode ? 'Dark' : 'Light'}');
    if (isDarkMode) {
      emit(DarkTheme());
    } else {
      emit(LightTheme());
    }
  }
}
