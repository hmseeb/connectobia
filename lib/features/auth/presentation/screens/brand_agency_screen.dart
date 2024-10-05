import 'package:connectobia/features/auth/application/signup/signup_bloc.dart';
import 'package:connectobia/features/auth/presentation/views/brand_signup_form.dart';
import 'package:connectobia/features/auth/presentation/views/privacy_policy.dart';
import 'package:connectobia/features/auth/presentation/widgets/heading_text.dart';
import 'package:connectobia/globals/constants/screen_size.dart';
import 'package:connectobia/globals/widgets/transparent_appbar.dart';
import 'package:connectobia/theme/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late String accountType;
  final accountTypes = {
    'brand': 'Brand',
    'agency': 'Agency',
  };

  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);

    return Scaffold(
        appBar: transparentAppBar('Create your account'),
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * 15),
                  const HeadingText('Match with the best creators'),
                  const SizedBox(height: 20),
                  BrandSignupForm(
                      firstNameController: firstNameController,
                      lastNameController: lastNameController,
                      emailController: emailController,
                      websiteController: websiteController,
                      passwordController: passwordController),
                  SizedBox(
                    width: double.infinity,
                    child: ShadSelect<String>(
                      placeholder: const Text('Select account type'),
                      options: [
                        ...accountTypes.entries.map((e) =>
                            ShadOption(value: e.key, child: Text(e.value))),
                      ],
                      selectedOptionBuilder: (context, value) =>
                          Text(accountTypes[value]!),
                      onChanged: (value) {
                        accountType = value;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const PrivacyPolicy(),
                  const SizedBox(height: 20),
                  PrimaryAuthButton(
                    text: 'Create account',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
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
