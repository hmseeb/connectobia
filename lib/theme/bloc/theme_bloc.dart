import 'package:bloc/bloc.dart';
import 'package:connectobia/db/shared_prefs.dart';
import 'package:flutter/material.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    on<ThemeEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<ThemeChanged>((event, emit) async {
      final prefs = await SharedPrefs.instance;
      await prefs.setBool('darkMode', event.isDark);
      debugPrint('Theme changed to ${event.isDark ? 'dark' : 'light'}');
      if (event.isDark) {
        emit(DarkTheme());
      } else {
        emit(LightTheme());
      }
    });
  }
}
