import 'package:connectobia/features/auth/presentation/views/connection_icon.dart';
import 'package:connectobia/features/auth/presentation/widgets/auth_flow.dart';
import 'package:connectobia/features/auth/presentation/widgets/heading_text.dart';
import 'package:connectobia/features/auth/presentation/widgets/signup_card.dart';
import 'package:connectobia/features/auth/presentation/widgets/tagline.dart';
import 'package:connectobia/globals/constants/screen_size.dart';
import 'package:connectobia/globals/widgets/transparent_appbar.dart';
import 'package:connectobia/theme/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class WelcomeScreen extends StatefulWidget {
  final bool isDarkMode;
  const WelcomeScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final ThemeCubit themeCubit;
  late bool isDarkMode;
  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);

    return Scaffold(
      appBar: transparentAppBar(
        '',
        actions: [
          IconButton(
            icon: Icon(isDarkMode
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined),
            onPressed: () {
              isDarkMode = !isDarkMode;
              themeCubit.toggleTheme(isDarkMode);
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeadingText('Welcome to '),
                ConnectionIcon(),
                HeadingText('bia'),
              ],
            ),
            const Tagline('where brands and influencers meet'),
            const SizedBox(height: 30),
            SignupCard(
              title: 'Brand or Agency',
              description: 'I want to grow my business',
              onPressed: () {
                Navigator.pushNamed(context, '/brand-agency-signup');
              },
            ),
            const SizedBox(height: 10),
            SignupCard(
              title: 'Influencer',
              description: 'I want to monetize my content',
              onPressed: () {
                Navigator.pushNamed(context, '/creator-signup');
              },
            ),
            const SizedBox(height: 30),
            AuthFlow(
              title: 'Already have an account? ',
              buttonText: 'Sign in',
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    themeCubit = BlocProvider.of<ThemeCubit>(context);
    isDarkMode = widget.isDarkMode;
  }
}
