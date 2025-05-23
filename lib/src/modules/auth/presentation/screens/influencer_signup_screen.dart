import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:social_auth_btn_kit/social_auth_btn_kit.dart';

import '../../../../shared/data/constants/assets.dart';
import '../../../../shared/data/constants/industries.dart';
import '../../../../shared/data/constants/screen_size.dart';
import '../../../../shared/presentation/widgets/custom_dialogue.dart';
import '../../../../shared/presentation/widgets/transparent_app_bar.dart';
import '../../../../theme/buttons.dart';
import '../../../../theme/colors.dart';
import '../../application/signup/signup_bloc.dart';
import '../widgets/custom_shad_select.dart';
import '../widgets/influencer_signup_form.dart';
import '../widgets/privacy_policy.dart';
import 'brand_signup_screen.dart';

/// A screen that allows a Influencer to sign up.
/// [InfluencerScreen] contains a form for a Influencer to sign up.
///
/// {@category Screens}
class InfluencerScreen extends StatefulWidget {
  const InfluencerScreen({super.key});

  @override
  State<InfluencerScreen> createState() => _InfluencerScreenState();
}

class _InfluencerScreenState extends State<InfluencerScreen> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController usernameController;
  late final signupBloc = BlocProvider.of<SignupBloc>(context);
  String accountType = 'influencers';
  String industry = '';
  var searchValue = '';
  bool enabled = true;
  FocusNode focusNodes = FocusNode();

  Map<String, String> get filteredIndustries => {
        for (final industry in IndustryList.industries.entries)
          if (industry.value.toLowerCase().contains(searchValue.toLowerCase()))
            industry.key: industry.value
      };

  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: transparentAppBar('Create influencer account', context: context),
      body: SingleChildScrollView(
        child: BlocConsumer<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              ShadToaster.of(context).show(
                ShadToast(
                  title: Text('Account created successfully!'),
                ),
              );
              Navigator.pushNamed(
                context,
                verifyEmailScreen,
                arguments: {'email': state.email},
              );
            } else if (state is InstagramSignupSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                influencerDashboard,
                (route) => false,
                arguments: {'user': state.influencer},
              );
            } else if (state is SignupFailure) {
              ShadToaster.of(context).show(
                ShadToast.destructive(
                  title: Text(state.error),
                ),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: SizedBox(
                width: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 2.5),
                    SizedBox(height: height * 2.5),
                    SvgPicture.asset(
                      AssetsPath.brand,
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(height: 20),
                    InfluencerSignupForm(
                        brandNameController: firstNameController,
                        emailController: emailController,
                        passwordController: passwordController),
                    const SizedBox(height: 10),
                    CustomShadSelect(
                      items: IndustryList.industries,
                      placeholder: 'Select industry...',
                      onSelected: (selectedIndustry) {
                        industry = selectedIndustry;
                      },
                      focusNode: focusNodes,
                    ),
                    const SizedBox(height: 20),
                    const PrivacyPolicy(),
                    const SizedBox(height: 20),
                    PrimaryButton(
                        isLoading: state is SignupLoading,
                        text: 'Create account',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          signupBloc.add(SignupInfluencerSubmitted(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            username: usernameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                            industry: industry,
                          ));
                        }),
                    const SizedBox(height: 20),
                    const OrDivider(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: SocialAuthBtn(
                        icon: AssetsPath.instagram,
                        onPressed: () {
                          customDialogue(
                              context: context,
                              title: 'You need an Instagram Business account',
                              description:
                                  'If you don\'t have one, you can create one by converting your personal account to a business account.',
                              onContinue: () {
                                HapticFeedback.mediumImpact();
                                BlocProvider.of<SignupBloc>(context).add(
                                    InstagramSignup(accountType: accountType));
                              });
                        },
                        text: state is InstagramLoading
                            ? 'Signing up...'
                            : state is InstagramFailure
                                ? 'An unexpected error occurred'
                                : 'Sign up with Instagram',
                        borderSide: const BorderSide(),
                        backgroundColor: ShadColors.lightForeground,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    usernameController = TextEditingController();
    super.initState();
  }
}
