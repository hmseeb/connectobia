import 'package:connectobia/common/constants/path.dart';
import 'package:connectobia/common/constants/screen_size.dart';
import 'package:connectobia/common/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/auth/application/login/login_bloc.dart';
import 'package:connectobia/modules/auth/presentation/screens/brand_screen.dart';
import 'package:connectobia/modules/auth/presentation/views/forget_password_sheet.dart';
import 'package:connectobia/modules/auth/presentation/views/login_form.dart';
import 'package:connectobia/modules/auth/presentation/widgets/auth_flow.dart';
import 'package:connectobia/theme/buttons.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:social_auth_btn_kit/social_auth_btn_kit.dart';

/// A screen that allows a user to sign in.
///
/// [SigninScreen] contains a form for a user to sign in.
///
/// {@category Screens}
class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final loginBloc = BlocProvider.of<LoginBloc>(context);
  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: transparentAppBar('Welcome back', context: context),
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
                  } else if (state is LoginSuccess) {
                    if (state.user.hasCompletedOnboarding) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/homeScreen',
                        (route) => false,
                        arguments: {'user': state.user},
                      );
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        state.user.accountType == 'influencer'
                            ? '/influencerOnboarding'
                            : '/brandOnboarding',
                        (route) => false,
                        arguments: {'user': state.user},
                      );
                    }
                  } else if (state is LoginUnverified) {
                    Navigator.pushNamed(
                      context,
                      '/verifyEmailScreen',
                      arguments: {'email': emailController.text},
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * 2),
                      SvgPicture.asset(
                        AssetsPath.login,
                        height: 150,
                        width: 150,
                      ),
                      const SizedBox(height: 20),
                      LoginForm(
                          emailController: emailController,
                          passwordController: passwordController),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              showShadSheet(
                                side: ShadSheetSide.bottom,
                                context: context,
                                builder: (context) => const ForgotPasswordSheet(
                                    side: ShadSheetSide.bottom),
                              );
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: ShadColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      PrimaryButton(
                          text: 'Sign in',
                          onPressed: () {
                            HapticFeedback.mediumImpact();

                            loginBloc.add(LoginSubmitted(
                                email: emailController.text,
                                password: passwordController.text));
                          },
                          isLoading: state is LoginLoading),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      const OrDivider(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: SocialAuthBtn(
                          icon: 'assets/icons/instagram.png',
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            BlocProvider.of<LoginBloc>(context)
                                .add(LoginWithInstagram());
                          },
                          text: state is InstagramLoading
                              ? 'Signing in with Instagram...'
                              : 'Sign in with Instagram',
                          borderSide: const BorderSide(),
                          backgroundColor: ShadColors.lightForeground,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthFlow(
                        title: 'Don\'t have an account? ',
                        buttonText: 'Sign up',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
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
