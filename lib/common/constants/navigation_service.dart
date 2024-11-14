import 'package:flutter/material.dart';

/// A class that holds the navigation service
///
/// This class is used to hold the navigation service that is used throughout the
/// application. This class is used to maintain a consistent navigation service
/// throughout the application.
///
/// {@category Constants}
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
