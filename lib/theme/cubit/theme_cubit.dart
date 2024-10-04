import 'package:bloc/bloc.dart';
import 'package:connectobia/db/shared_prefs.dart';
import 'package:flutter/material.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial());

  void toggleTheme(bool isDarkMode) async {
    final prefs = await SharedPrefs.instance;
    await prefs.setBool('darkMode', isDarkMode);

    if (isDarkMode) {
      emit(DarkTheme());
    } else {
      emit(LightTheme());
    }
  }
}
