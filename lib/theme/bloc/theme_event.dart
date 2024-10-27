part of 'theme_bloc.dart';

class ThemeChanged extends ThemeEvent {
  final bool isDark;

  ThemeChanged(this.isDark);
}

@immutable
sealed class ThemeEvent {}
