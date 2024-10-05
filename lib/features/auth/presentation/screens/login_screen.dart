import 'package:connectobia/features/auth/application/login/login_bloc.dart';
import 'package:connectobia/features/auth/presentation/views/login_form.dart';
import 'package:connectobia/features/auth/presentation/widgets/auth_flow.dart';
import 'package:connectobia/features/auth/presentation/widgets/heading_text.dart';
import 'package:connectobia/globals/constants/screen_size.dart';
import 'package:connectobia/globals/widgets/transparent_appbar.dart';
import 'package:connectobia/theme/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
        appBar: transparentAppBar('Sign in to your account'),
        body: SingleChildScrollView(
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
                }
                if (state is LoginSuccess) {
                  Navigator.pop(context);
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * 15),
                    const HeadingText('Log in to your account'),
                    const SizedBox(height: 20),
                    LoginForm(
                        emailController: emailController,
                        passwordController: passwordController),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    PrimaryAuthButton(
                        text: 'Sign in',
                        onPressed: () {
                          loginBloc.add(LoginSubmitted(
                              email: emailController.text,
                              password: passwordController.text));
                        },
                        isLoading: state is LoginLoading),
                    const SizedBox(height: 20),
                    AuthFlow(
                      title: 'Don\'t have an account? ',
                      buttonText: 'Sign up',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        )));
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
