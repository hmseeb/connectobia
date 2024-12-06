import 'package:connectobia/common/constants/industries.dart';
import 'package:connectobia/common/constants/screen_size.dart';
import 'package:connectobia/common/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/auth/application/signup/signup_bloc.dart';
import 'package:connectobia/modules/auth/presentation/screens/brand_screen.dart';
import 'package:connectobia/modules/auth/presentation/views/creator_signup_form.dart';
import 'package:connectobia/modules/auth/presentation/widgets/auth_flow.dart';
import 'package:connectobia/modules/auth/presentation/widgets/custom_shad_select.dart';
import 'package:connectobia/modules/auth/presentation/widgets/privacy_policy.dart';
import 'package:connectobia/theme/buttons.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:social_auth_btn_kit/social_auth_btn_kit.dart';

/// A screen that allows a creator to sign up.
/// [CreatorScreen] contains a form for a creator to sign up.
///
/// {@category Screens}
class CreatorScreen extends StatefulWidget {
  const CreatorScreen({super.key});

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController usernameController;
  late final signupBloc = BlocProvider.of<SignupBloc>(context);
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
      appBar: transparentAppBar('Create your account', context: context),
      body: SingleChildScrollView(
        child: BlocConsumer<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              // Navigator.of(context).pushNamed('/login');
              Navigator.pushNamed(
                context,
                '/verifyEmailScreen',
                arguments: {'email': emailController.text},
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
                  children: <Widget>[
                    SizedBox(height: height * 2),
                    const SizedBox(height: 20),
                    CreatorSignupForm(
                        firstNameController: firstNameController,
                        lastNameController: lastNameController,
                        emailController: emailController,
                        usernameController: usernameController,
                        passwordController: passwordController),
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
                        icon: 'assets/icons/instagram.png',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          BlocProvider.of<SignupBloc>(context)
                              .add(InstagramSignup());
                        },
                        text: state is InstagramLoading
                            ? 'Signing up...'
                            : 'Sign up with Instagram',
                        borderSide: const BorderSide(),
                        backgroundColor: ShadColors.lightForeground,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthFlow(
                      title: 'Already have an account? ',
                      buttonText: 'Sign in',
                      onPressed: () {
                        Navigator.pushNamed(context, '/signinScreen');
                        HapticFeedback.mediumImpact();
                      },
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
