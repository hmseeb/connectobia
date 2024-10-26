import 'package:connectobia/src/globals/constants/industries.dart';
import 'package:connectobia/src/globals/constants/path.dart';
import 'package:connectobia/src/globals/constants/screen_size.dart';
import 'package:connectobia/src/globals/widgets/transparent_appbar.dart';
import 'package:connectobia/src/modules/auth/application/signup/signup_bloc.dart';
import 'package:connectobia/src/modules/auth/presentation/views/creator_signup_form.dart';
import 'package:connectobia/src/modules/auth/presentation/views/privacy_policy.dart';
import 'package:connectobia/src/modules/auth/presentation/widgets/auth_flow.dart';
import 'package:connectobia/src/modules/auth/presentation/widgets/heading_text.dart';
import 'package:connectobia/src/theme/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
  late final signupBloc = BlocProvider.of<SignupBloc>(context);
  String industry = '';
  var searchValue = '';
  bool enabled = true;
  FocusNode focusNodes = FocusNode();

  Map<String, String> get filteredIndustries => {
        for (final industry in industries.entries)
          if (industry.value.toLowerCase().contains(searchValue.toLowerCase()))
            industry.key: industry.value
      };

  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);

    return Scaffold(
      appBar: transparentAppBar('Create your account'),
      body: SingleChildScrollView(
        child: BlocConsumer<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              // Navigator.of(context).pushNamed('/login');
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
                    SizedBox(height: height * 7),
                    SvgPicture.asset(
                      AssetsPath.creator,
                      height: 200,
                      width: 200,
                    ),
                    const SizedBox(height: 20),
                    const HeadingText('Collaborate with the best brands'),
                    const SizedBox(height: 20),
                    CreatorSignupForm(
                        firstNameController: firstNameController,
                        lastNameController: lastNameController,
                        emailController: emailController,
                        passwordController: passwordController),
                    ShadSelect<String>.withSearch(
                      enabled: enabled,
                      focusNode: focusNodes,
                      minWidth: 350,
                      maxWidth: 350,
                      placeholder: const Text('Select industry...'),
                      onSearchChanged: (value) =>
                          setState(() => searchValue = value),
                      searchPlaceholder: const Text('Search industry'),
                      options: [
                        if (filteredIndustries.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('No industry found'),
                          ),
                        ...industries.entries.map(
                          (industry) {
                            // this offstage is used to avoid the focus loss when the search results appear again
                            // because it keeps the widget in the tree.
                            return Offstage(
                              offstage:
                                  !filteredIndustries.containsKey(industry.key),
                              child: ShadOption(
                                value: industry.key,
                                child: Text(industry.value),
                              ),
                            );
                          },
                        )
                      ],
                      selectedOptionBuilder: (context, value) {
                        industry = value;
                        return Text(industries[value] ?? '');
                      },
                    ),
                    const SizedBox(height: 20),
                    const PrivacyPolicy(),
                    const SizedBox(height: 20),
                    PrimaryAuthButton(
                        isLoading: state is SignupLoading,
                        text: 'Create account',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          signupBloc.add(SignupInfluencerSubmitted(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                            industry: industry,
                          ));
                        }),
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
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }
}
