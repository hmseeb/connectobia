import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/data/constants/industries.dart';
import '../../../../shared/data/constants/path.dart';
import '../../../../shared/data/constants/screen_size.dart';
import '../../../../shared/presentation/widgets/transparent_appbar.dart';
import '../../../../theme/buttons.dart';
import '../../application/signup/signup_bloc.dart';
import '../widgets/brand_signup_form.dart';
import '../widgets/custom_shad_select.dart';
import '../widgets/privacy_policy.dart';

/// A screen that allows a brand to sign up.
/// [BrandScreen] contains a form for a brand to sign up.
///
/// {@category Screens}
class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('OR'),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _BrandScreenState extends State<BrandScreen> {
  late final TextEditingController brandNameController;
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final signupBloc = BlocProvider.of<SignupBloc>(context);

  final FocusNode industryFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  String accountType = 'brands';
  String industry = '';
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: transparentAppBar('Create your account', context: context),
      body: SingleChildScrollView(
        controller: scrollController,
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
                '/verifyEmailScreen',
                arguments: {'email': state.email},
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
                    SvgPicture.asset(
                      AssetsPath.brand,
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(height: 20),
                    BrandSignupForm(
                      brandNameController: brandNameController,
                      usernameController: usernameController,
                      emailController: emailController,
                      passwordController: passwordController,
                      industry: CustomShadSelect(
                        items: IndustryList.industries,
                        placeholder: 'Select industry...',
                        onSelected: (selectedIndustry) {
                          industry = selectedIndustry;
                        },
                        focusNode: industryFocusNode,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const PrivacyPolicy(),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: 'Create account',
                      isLoading: state is SignupLoading,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        signupBloc.add(SignupBrandSubmitted(
                          brandName: brandNameController.text,
                          username: usernameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                          industry: industry,
                        ));
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
    brandNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    industryFocusNode.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController();
    emailController = TextEditingController();
    brandNameController = TextEditingController();
    passwordController = TextEditingController();

    // Listen to focus changes to trigger scroll adjustments
  }
}
