import 'package:connectobia/app.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// The entry point of the application
///
/// {@category Main}
void main() async {
  /// Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Rive
  await RiveFile.initialize();
  runApp(const Connectobia());
}
