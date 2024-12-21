import 'package:shared_preferences/shared_preferences.dart';

/// Singleton class to manage the SharedPrefs instance
///
/// This class is used to create a single instance of the SharedPrefs class
/// that can be used throughout the application.
///
/// {@category Database}
class SharedPrefs {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
