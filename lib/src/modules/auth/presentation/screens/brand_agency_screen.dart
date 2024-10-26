import 'package:connectobia/src/globals/constants/path.dart';
import 'package:connectobia/src/globals/constants/screen_size.dart';
import 'package:connectobia/src/globals/widgets/transparent_appbar.dart';
import 'package:connectobia/src/modules/auth/application/signup/signup_bloc.dart';
import 'package:connectobia/src/modules/auth/presentation/views/brand_signup_form.dart';
import 'package:connectobia/src/modules/auth/presentation/views/privacy_policy.dart';
import 'package:connectobia/src/modules/auth/presentation/widgets/auth_flow.dart';
import 'package:connectobia/src/modules/auth/presentation/widgets/heading_text.dart';
import 'package:connectobia/src/theme/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BrandAgencyScreen extends StatefulWidget {
  const BrandAgencyScreen({super.key});

  @override
  State<BrandAgencyScreen> createState() => _BrandAgencyScreenState();
}

class _BrandAgencyScreenState extends State<BrandAgencyScreen> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController websiteController;
  late final TextEditingController passwordController;
  late final signupBloc = BlocProvider.of<SignupBloc>(context);
  String accountType = 'brand';

  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);

    return Scaffold(
        appBar: transparentAppBar('Create your account'),
        body: SingleChildScrollView(
          child: BlocConsumer<SignupBloc, SignupState>(
            listener: (context, state) {
              if (state is SignupSuccess) {
                Navigator.pushNamed(
                  context,
                  '/verify-email',
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
                      SizedBox(height: height * 5),
                      SvgPicture.asset(
                        AssetsPath.brand,
                        height: 150,
                        width: 150,
                      ),
                      const SizedBox(height: 20),
                      const HeadingText('Match with the best creators'),
                      const SizedBox(height: 20),
                      BrandSignupForm(
                          firstNameController: firstNameController,
                          lastNameController: lastNameController,
                          emailController: emailController,
                          websiteController: websiteController,
                          passwordController: passwordController),
                      const SizedBox(height: 20),
                      const PrivacyPolicy(),
                      const SizedBox(height: 20),
                      PrimaryAuthButton(
                        text: 'Create account',
                        isLoading: state is SignupLoading,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          signupBloc.add(SignupBrandSubmitted(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            website: websiteController.text,
                            password: passwordController.text,
                          ));
                        },
                      ),
                      const SizedBox(height: 20),
                      AuthFlow(
                        title: 'Already have an account? ',
                        buttonText: 'Sign in',
                        onPressed: () {
                          Navigator.pushNamed(context, '/signin');
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    websiteController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    websiteController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }
}
