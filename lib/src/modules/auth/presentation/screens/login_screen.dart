import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:social_auth_btn_kit/social_auth_btn_kit.dart';

import '../../../../shared/data/constants/assets.dart';
import '../../../../shared/data/constants/screen_size.dart';
import '../../../../shared/presentation/widgets/transparent_app_bar.dart';
import '../../../../theme/buttons.dart';
import '../../../../theme/colors.dart';
import '../../../onboarding/application/bloc/influencer_onboard_bloc.dart';
import '../../application/login/login_bloc.dart';
import '../widgets/auth_flow.dart';
import '../widgets/forget_password_sheet.dart';
import '../widgets/login_form.dart';
import 'brand_signup_screen.dart';

/// A screen that allows a user to Log in.
///
/// [LoginScreen] contains a form for a user to Log in.
///
/// {@category Screens}
class LoginScreen extends StatefulWidget {
  final String accountType;
  const LoginScreen({super.key, required this.accountType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final loginBloc = BlocProvider.of<LoginBloc>(context);
  @override
  Widget build(BuildContext context) {
    String accountType = widget.accountType;
    final height = ScreenSize.height(context);

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: transparentAppBar(
            accountType == 'brands'
                ? 'Connect with Influencers'
                : 'Connect with Brands',
            context: context),
        body: PopScope(
          child: SingleChildScrollView(
              child: Center(
            child: SizedBox(
              width: 350,
              child: BlocConsumer<LoginBloc, LoginBlocState>(
                listener: (context, state) {
                  if (state is LoginFailure) {
                    ShadToaster.of(context).show(
                      ShadToast.destructive(
                        title: Text(state.error),
                      ),
                    );
                  } else if (state is BrandLoginSuccess) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      brandDashboard,
                      (route) => false,
                      arguments: {'user': state.user},
                    );
                  } else if (state is InfluencerLoginSuccess) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      influencerDashboard,
                      (route) => false,
                      arguments: {'user': state.user},
                    );
                  } else if (state is LoginUnverified) {
                    Navigator.pushNamed(
                      context,
                      verifyEmailScreen,
                      arguments: {'email': emailController.text},
                    );
                  } else if (state is ConnectingInstagramFailure) {
                    ShadToaster.of(context).show(
                      ShadToast.destructive(
                        title: Text(
                            'An error occurred while connecting Instagram'),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * 2.5),
                      SvgPicture.asset(
                        AssetsPath.login,
                        height: 150,
                        width: 150,
                      ),
                      const SizedBox(height: 20),
                      LoginForm(
                          emailController: emailController,
                          passwordController: passwordController),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            showShadSheet(
                              side: ShadSheetSide.bottom,
                              context: context,
                              builder: (context) => ForgotPasswordSheet(
                                side: ShadSheetSide.bottom,
                                accountType: widget.accountType,
                              ),
                            );
                          },
                          child: Text('Forgot password?',
                              style: TextStyle(
                                color: ShadColors.primary,
                              )),
                        ),
                      ),
                      PrimaryButton(
                          text: 'Log in',
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            loginBloc.add(LoginSubmitted(
                              email: emailController.text,
                              password: passwordController.text,
                              accountType: accountType,
                            ));
                          },
                          isLoading: state is LoginLoading),
                      if (accountType == 'influencers') ...[
                        const SizedBox(height: 20),
                        const OrDivider(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: SocialAuthBtn(
                            icon: AssetsPath.instagram,
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              BlocProvider.of<LoginBloc>(context)
                                  .add(InstagramAuth(accountType: accountType));
                            },
                            text: state is InstagramLoading
                                ? 'Logging in with Instagram...'
                                : 'Login with Instagram',
                            borderSide: const BorderSide(),
                            backgroundColor: ShadColors.lightForeground,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      AuthFlow(
                        title: 'Don\'t have an account? ',
                        buttonText: 'Sign up',
                        onPressed: () {
                          if (accountType == 'brands') {
                            Navigator.pushNamed(
                              context,
                              brandSignupScreen,
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              influencerSignupScreen,
                            );
                          }
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          )),
        ));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }
}
