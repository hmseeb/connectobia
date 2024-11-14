import 'package:connectobia/app.dart';
import 'package:connectobia/modules/auth/application/auth/auth_bloc.dart';
import 'package:connectobia/modules/auth/application/login/login_bloc.dart';
import 'package:connectobia/modules/auth/application/signup/signup_bloc.dart';
import 'package:connectobia/modules/auth/application/verification/email_verification_bloc.dart';
import 'package:connectobia/modules/dashboard/application/animation/animation_cubit.dart';
import 'package:connectobia/modules/dashboard/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'package:connectobia/modules/dashboard/application/edit_profile/edit_profile_bloc.dart';
import 'package:connectobia/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocProviders extends StatelessWidget {
  final bool isDarkMode;

  const BlocProviders({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => ThemeBloc()..add(ThemeChanged(isDarkMode))),
        BlocProvider(create: (context) => LoginBloc()),
        BlocProvider(create: (context) => SignupBloc()),
        BlocProvider(create: (context) => EmailVerificationBloc()),
        BlocProvider(create: (context) => BrandDashboardBloc()),
        BlocProvider(create: (context) => EditProfileBloc()),
        BlocProvider(create: (context) => AuthBloc()..add(CheckAuth())),
        BlocProvider(create: (context) => AnimationCubit()),
      ],
      child: Connectobia(
        isDarkMode: isDarkMode,
      ),
    );
  }
}
