import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      themeMode: ThemeMode.light,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadColorScheme(
          foreground: Colors.black,
          primary: Colors.white,
          secondary: Colors.red,
          background: Colors.black,
          card: Colors.white,
          cardForeground: Colors.black,
          popover: Colors.white,
          popoverForeground: Colors.black,
          primaryForeground: Colors.black,
          secondaryForeground: Colors.black,
          muted: Colors.grey,
          mutedForeground: Colors.black,
          accent: Colors.blue,
          accentForeground: Colors.black,
          destructive: Colors.red,
          destructiveForeground: Colors.black,
          border: Colors.grey,
          input: Colors.white,
          ring: Colors.blue,
          selection: Colors.blue,
        ),
      ),
      title: 'Connectobia',
      home: const ShadButton(
        onPressed: null,
        child: ShadButton(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
