import 'package:connectobia/globals/constants/industries.dart';
import 'package:connectobia/globals/constants/path.dart';
import 'package:connectobia/globals/constants/screen_size.dart';
import 'package:connectobia/globals/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/auth/application/signup/signup_bloc.dart';
import 'package:connectobia/modules/auth/presentation/views/brand_signup_form.dart';
import 'package:connectobia/modules/auth/presentation/widgets/auth_flow.dart';
import 'package:connectobia/modules/auth/presentation/widgets/custom_shad_select.dart';
import 'package:connectobia/modules/auth/presentation/widgets/heading_text.dart';
import 'package:connectobia/modules/auth/presentation/widgets/privacy_policy.dart';
import 'package:connectobia/theme/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A screen that allows a brand to sign up.
/// [BrandScreen] contains a form for a brand to sign up.
///
/// {@category Screens}
class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController websiteController;
  late final TextEditingController passwordController;
  late final signupBloc = BlocProvider.of<SignupBloc>(context);

  final FocusNode industryFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  String accountType = 'brand';
  String industry = '';
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: transparentAppBar('Create your account'),
      body: SingleChildScrollView(
        controller: scrollController,
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
                  children: [
                    SizedBox(height: height * 2),
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
                      passwordController: passwordController,
                    ),
                    CustomShadSelect(
                      items: industries,
                      placeholder: 'Select industry...',
                      onSelected: (selectedIndustry) {
                        industry = selectedIndustry;
                      },
                      focusNode: industryFocusNode,
                    ),
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
                          industry: industry,
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
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    websiteController.dispose();
    passwordController.dispose();
    industryFocusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    websiteController = TextEditingController();
    passwordController = TextEditingController();

    // Listen to focus changes to trigger scroll adjustments
  }
}
