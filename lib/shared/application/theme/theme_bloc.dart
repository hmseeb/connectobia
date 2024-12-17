import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../services/storage/shared_prefs.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<ThemeChanged>((event, emit) async {
      final prefs = await SharedPrefs.instance;
      await prefs.setBool('darkMode', event.isDark);
      debugPrint('Theme mode set to ${event.isDark ? 'dark' : 'light'}');
      if (event.isDark) {
        emit(DarkTheme());
      } else {
        emit(LightTheme());
      }
    });
  }
}
