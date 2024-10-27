import 'package:connectobia/db/db.dart';
import 'package:connectobia/globals/widgets/transparent_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int count = 1;
  @override
  Widget build(BuildContext context) {
    final themeMode = ShadTheme.of(context).brightness;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            count++;
          });
        },
        child: const Icon(Icons.add),
      ),
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
      body: Center(
        child: Text(count.toString()),
      ),
    );
  }
}
