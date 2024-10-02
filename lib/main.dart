import 'package:connectobia/routes.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: ShadApp(
        initialRoute: '/',
        onGenerateRoute: (settings) => GenerateRoutes.onGenerateRoute(settings),
        themeMode: ThemeMode.light,
        theme: ShadThemeData(
          brightness: Brightness.light,
          colorScheme: const ShadSlateColorScheme.light(
            primary: Color(0xff212121),
            secondary: Colors.redAccent,
            background: Colors.white,
            foreground: Colors.black,
          ),
        ),
        title: 'Connectobia',
      ),
    );
  }
}
