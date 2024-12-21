import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_auth_btn_kit/social_auth_btn_kit.dart';

import '../../../../shared/data/constants/path.dart';
import '../../../../shared/data/constants/screen_size.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../../../theme/colors.dart';
import '../../application/bloc/influencer_onboard_bloc.dart';

class InfluencerOnboarding extends StatefulWidget {
  final Influencer user;

  const InfluencerOnboarding({super.key, required this.user});

  @override
  State<InfluencerOnboarding> createState() => _InfluencerOnboardingState();
}

class _InfluencerOnboardingState extends State<InfluencerOnboarding> {
  final TextEditingController locationName = TextEditingController();
  String instagramButtonText = 'Connect Instagram';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfluencerOnboardBloc, InfluencerOnboardState>(
      listener: (context, state) {
        if (state is Onboarded) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/influencerDashboard', (route) => false,
              arguments: {'influencers': widget.user});
        } else if (state is ConnectingInstagram) {
          setState(() {
            instagramButtonText = 'Connecting Instagram...';
          });
        } else if (state is ConnectingInstagramFailure) {
          setState(() {
            instagramButtonText = 'Connect Instagram';
          });
        }
      },
      builder: (context, state) {
        final height = ScreenSize.height(context);
        return Scaffold(
          body: Center(
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetsPath.onboardInfluencer,
                    height: height * 50,
                    width: 150,
                  ),
                  Text(
                    'Connect your Instagram account',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Get verified and increase your chances of getting hired.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: SocialAuthBtn(
                      icon: AssetsPath.instagram,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        BlocProvider.of<InfluencerOnboardBloc>(context)
                            .add(ConnectInstagram());
                      },
                      text: instagramButtonText,
                      borderSide: const BorderSide(),
                      backgroundColor: ShadColors.lightForeground,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      BlocProvider.of<InfluencerOnboardBloc>(context)
                          .add(UpdateOnboardBool());
                      HapticFeedback.mediumImpact();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/influencerDashboard', (route) => false,
                          arguments: {'influencers': widget.user});
                    },
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: ShadColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
