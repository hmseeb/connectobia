import 'package:connectobia/src/app.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/contract/contract_bloc.dart';
import 'package:connectobia/src/modules/chatting/application/chats/chats_bloc.dart';
import 'package:connectobia/src/modules/chatting/application/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/modules/notifications/application/notification_bloc.dart';
import 'package:connectobia/src/modules/profile/application/favorites/favorites_bloc.dart';
import 'package:connectobia/src/modules/profile/application/user/user_bloc.dart';
import 'package:connectobia/src/modules/wallet/application/wallet/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'modules/auth/application/auth/auth_bloc.dart';
import 'modules/auth/application/login/login_bloc.dart';
import 'modules/auth/application/signup/signup_bloc.dart';
import 'modules/auth/application/verification/email_verification_bloc.dart';
import 'modules/dashboard/brand/application/brand_dashboard/brand_dashboard_bloc.dart';
import 'modules/dashboard/brand/application/profile_settings/profile_settings.dart';
import 'modules/dashboard/common/application/brand_profile/brand_profile_bloc.dart';
import 'modules/dashboard/common/application/influencer_profile/influencer_profile_bloc.dart';
import 'modules/dashboard/influencer/application/influencer_dashboard/influencer_dashboard_bloc.dart';
import 'modules/onboarding/application/bloc/influencer_onboard_bloc.dart';
import 'shared/application/animation/animation_cubit.dart';
import 'shared/application/theme/theme_bloc.dart';

/// [BlocProviders] is a widget that provides all the necessary blocs to the application.
/// It is a wrapper around the [Connectobia] widget.
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
        BlocProvider(
            create: (context) =>
                BrandDashboardBloc()..add(BrandDashboardLoadInfluencers())),
        BlocProvider(
            create: (context) => InfluencerDashboardBloc()
              ..add(InfluencerDashboardLoadBrands())),
        BlocProvider(create: (context) => BrandProfileBloc()),
        BlocProvider(create: (context) => ProfileSettingsBloc()),
        BlocProvider(create: (context) => AuthBloc()..add(CheckAuth())),
        BlocProvider(create: (context) => InfluencerProfileBloc()),
        BlocProvider(create: (context) => InfluencerOnboardBloc()),
        BlocProvider(create: (context) => AnimationCubit()),
        BlocProvider(create: (context) => ChatsBloc()),
        BlocProvider(create: (context) => CampaignBloc()),
        BlocProvider(create: (context) => ContractBloc()),
        BlocProvider(create: (context) => UserBloc()),
        BlocProvider(create: (context) => WalletBloc()),
        BlocProvider(create: (context) => FavoritesBloc()),
        BlocProvider(
            create: (context) =>
                RealtimeMessagingBloc()..add(SubscribeMessages())),
        BlocProvider(
            create: (context) => NotificationBloc()
              ..add(InitializeNotificationService())
              ..add(SubscribeToNotifications())),
      ],
      child: Connectobia(
        isDarkMode: isDarkMode,
      ),
    );
  }
}
