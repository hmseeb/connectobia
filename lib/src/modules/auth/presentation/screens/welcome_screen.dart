import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/application/theme/theme_bloc.dart';
import '../../../../shared/data/constants/screen_size.dart';
import '../../../../shared/data/singletons/account_type.dart';
import '../../../../shared/presentation/widgets/transparent_app_bar.dart';
import '../widgets/signup_card.dart';
import '../widgets/tagline.dart';
import '../widgets/title_logo.dart';

/// A screen that allows a user to sign up or Log in.
///
/// [WelcomeScreen] contains a welcome message and two buttons for a user to sign up as a brand or influencer.
///
/// {@category Screens}
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final ThemeBloc themeBloc;

  @override
  Widget build(BuildContext context) {
    late final shadTheme = ShadTheme.of(context);
    bool isDarkMode = shadTheme.brightness == Brightness.dark;
    final height = ScreenSize.height(context);

    return Scaffold(
      appBar: transparentAppBar(
        '',
        context: context,
        actions: [
          IconButton(
            icon: Icon(isDarkMode
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined),
            onPressed: () {
              HapticFeedback.mediumImpact();
              isDarkMode = !isDarkMode;
              themeBloc.add(ThemeChanged(isDarkMode));
              ShadToaster.of(context).show(
                ShadToast(
                  description:
                      Text('Switched to ${isDarkMode ? 'dark' : 'light'} mode'),
                ),
              );
            },
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: height * 15),
            const AppTitleLogo(),
            const Tagline('where brands and influencers meet'),
            const SizedBox(height: 30),
            SignupCard(
              title: 'Brand or Agency',
              description: 'I want to grow my brand',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  loginScreen,
                  arguments: {
                    'accountType': 'brands',
                  },
                );
                HapticFeedback.mediumImpact();
                CollectionNameSingleton.instance = 'brands';
              },
            ),
            const SizedBox(height: 10),
            SignupCard(
              title: 'Influencer',
              description: 'I want to monetize my content',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  loginScreen,
                  arguments: {'accountType': 'influencers'},
                );
                HapticFeedback.mediumImpact();
                CollectionNameSingleton.instance = 'influencers';
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    themeBloc = BlocProvider.of<ThemeBloc>(context);
  }
}
