import 'package:connectobia/db/pb.dart';
import 'package:connectobia/globals/widgets/transparent_appbar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = ShadTheme.of(context).brightness;
    return Scaffold(
      appBar: transparentAppBar('', actions: [
        IconButton(
          icon: const Icon(Icons.logout_outlined),
          onPressed: () async {
            HapticFeedback.mediumImpact();

            final pb = await PocketBaseSingleton.instance;
            pb.authStore.clear();
            if (context.mounted) {
              Navigator.pushReplacementNamed(
                context,
                '/welcome',
                arguments: {'isDarkMode': themeMode == Brightness.dark},
              );
            }
          },
        ),
      ]),
      body: const Center(
        child: Text('Home'),
      ),
    );
  }
}
