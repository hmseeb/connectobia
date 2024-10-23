import 'package:connectobia/src/app.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart'; // Import the Rive package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RiveFile.initialize(); // Ensure Rive is initialized
  runApp(const Connectobia());
}
