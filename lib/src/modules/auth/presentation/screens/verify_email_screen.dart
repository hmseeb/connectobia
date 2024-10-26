import 'dart:async';

import 'package:connectobia/src/globals/constants/path.dart';
import 'package:connectobia/src/modules/auth/application/email_verification/email_verification_bloc.dart';
import 'package:connectobia/src/modules/auth/data/respository/auth_repo.dart';
import 'package:connectobia/src/modules/auth/presentation/widgets/heading_text.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VerifyEmail extends StatefulWidget {
  final String email;
  const VerifyEmail({super.key, required this.email});

  @override
  VerifyEmailState createState() => VerifyEmailState();
}

class VerifyEmailState extends State<VerifyEmail> {
  bool _canResendEmail = false;
  int _secondsRemaining = 30; // Countdown duration
  int _resendEmailCount = 0;
  late final blocProvider = BlocProvider.of<EmailVerificationBloc>(context);

  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmailVerificationBloc, EmailVerificationState>(
      listener: (context, state) {
        if (state is EmailVerified) {
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Email verified successfully'),
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                SvgPicture.asset(
                  AssetsPath.emailIcon,
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 20),
                const HeadingText('Almost done!'),
                const SizedBox(height: 20),
                const Text('A verification email has been sent to'),
                const SizedBox(height: 10),
                Text(widget.email,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text(
                  'Please check your inbox and follow the link to activate your account.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Didn't get the email?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Didn\'t get the email? ',
                      style: TextStyle(color: ShadColors.kPrimary),
                    ),
                    GestureDetector(
                      onTap: _canResendEmail
                          ? () {
                              _resendEmail(context);
                            }
                          : null,
                      child: Text(
                        _canResendEmail
                            ? 'Resend email'
                            : 'Resend in $_secondsRemaining seconds',
                        style: TextStyle(
                          color: _canResendEmail
                              ? ShadColors.kSecondary
                              : ShadColors.kDisabled,
                          fontWeight: _canResendEmail
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // open email button using url launcher
                ShadButton(
                  onPressed: () {
                    openEmailApp();
                  },
                  child: const Text('Open Email App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    blocProvider.add(EmailSubscribeEvent());
  }

  Future<void> openEmailApp() async {
    try {
      await OpenMailApp.openMailApp();
    } catch (e) {
      if (mounted) {
        // Show error toast
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: Text(e.toString()),
          ),
        );
      }
    }
  }

  void _resendEmail(BuildContext context) async {
    try {
      await AuthRepo.verifyEmail(widget.email);
      if (context.mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Email resent'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: Text(e.toString()),
          ),
        );
      }
    }

    _resendEmailCount++;
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _secondsRemaining += 30 * _resendEmailCount; // Reset timer to 30 seconds
      _canResendEmail = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResendEmail = true;
          _timer?.cancel();
        }
      });
    });
  }
}
