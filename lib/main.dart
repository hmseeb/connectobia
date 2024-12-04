import 'package:connectobia/common/widgets/bloc_providers.dart';
import 'package:connectobia/db/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rive/rive.dart';

/// The entry point of the application
///
/// {@category Main}
void main() async {
  /// Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize shared preferences
  final prefs = await SharedPrefs.instance;

  /// Get the brightness of the platform
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  /// Check if the user has set the dark mode preference
  bool isDarkMode =
      prefs.getBool('darkMode') ?? (brightness == Brightness.dark);

  /// Initialize Rive
  await RiveFile.initialize();
  runApp(BlocProviders(isDarkMode: isDarkMode));
}
