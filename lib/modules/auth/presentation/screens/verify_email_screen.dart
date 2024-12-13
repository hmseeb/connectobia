import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/constants/path.dart';
import '../../../../common/constants/screen_size.dart';
import '../../../../common/domain/repositories/error_repository.dart';
import '../../../../db/db.dart';
import '../../../../theme/colors.dart';
import '../../application/verification/email_verification_bloc.dart';
import '../../data/respository/auth_repo.dart';
import '../widgets/heading_text.dart';
import '../widgets/sub_heading.dart';

/// A screen that allows a user to verify their email.
///
/// [VerifyEmail] contains a message to the user to verify their email.
///
/// {@category Screens}
class VerifyEmail extends StatefulWidget {
  final String email;
  const VerifyEmail({super.key, required this.email});

  @override
  VerifyEmailState createState() => VerifyEmailState();
}

class VerifyEmailState extends State<VerifyEmail> {
  bool _canResendEmail = false;
  int _secondsRemaining = 30; // Countdown duration
  int _resendEmailCount = 1;
  bool isLoading = false;

  late final blocProvider = BlocProvider.of<EmailVerificationBloc>(context);

  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);
    return BlocListener<EmailVerificationBloc, EmailVerificationState>(
      listener: (context, state) {
        if (state is BrandEmailVerified) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/brandDashboard', (route) => false,
              arguments: {
                'user': state.brand,
              });
        } else if (state is InfluencerEmailVerified) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/influencerOnboarding', (route) => false,
              arguments: {
                'user': state.influencer,
              });
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
                  height: height * 30,
                ),
                const HeadingText('Verify your email'),
                const SizedBox(height: 20),
                const SubHeading('A verification email has been sent to'),
                const SizedBox(height: 10),
                Text(widget.email,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const SubHeading(
                    'Please check your inbox and follow the link to activate your account.'),
                const SizedBox(height: 20),
                // Didn't get the email?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Didn\'t get the email? ',
                    ),
                    GestureDetector(
                      onTap: _canResendEmail
                          ? () {
                              _resendEmail(context);
                            }
                          : null,
                      child: Text(
                        isLoading
                            ? 'Resending email...'
                            : _canResendEmail
                                ? 'Resend email'
                                : 'Resend in $_secondsRemaining seconds',
                        style: TextStyle(
                          color: _canResendEmail
                              ? ShadColors.primary
                              : ShadColors.disabled,
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
                SizedBox(
                  width: double.infinity,
                  child: ShadButton(
                    onPressed: () async {
                      await openEmailApp();
                    },
                    child: const Text('Open Email App'),
                  ),
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
    _authChecker();
  }

  /// Open the email app
  ///
  /// This function uses the [OpenMailApp] package to open the email app.
  /// TODO: Implement mail app
  Future<void> openEmailApp() async {
    try {
      if (Platform.isAndroid) {
        AndroidIntent intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          category: 'android.intent.category.APP_EMAIL',
        );
        intent.launch().catchError((e) {});
      } else if (Platform.isIOS) {
        launchUrl(Uri.parse('message://'));
      } else {
        launchUrl(Uri.parse('mailto:'));
      }
    } catch (e) {
      if (mounted) {
        // Show error toast
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: Text(e.toString()),
          ),
        );
      }
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Check if the user is authenticated
  ///
  /// This function checks if the user is authenticated and if not
  /// listens for changes in the authentication state.
  Future<void> _authChecker() async {
    final pb = await PocketBaseSingleton.instance;
    if (pb.authStore.isValid) {
      blocProvider.add(EmailSubscribeEvent());
    } else {
      _authListener(pb);
    }
  }

  /// Listen for changes in the authentication state
  ///
  /// This function listens for changes in the authentication state and
  /// dispatches an [EmailSubscribeEvent] when the user is authenticated.
  Future<void> _authListener(PocketBase pb) async {
    pb.authStore.onChange.listen((event) {
      if (event.token.isNotEmpty) {
        blocProvider.add(EmailSubscribeEvent());
      }
    });
  }

  /// Resend the verification email
  ///
  /// This function resends the verification email to the user's email address.
  void _resendEmail(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      await AuthRepo.verifyEmail(email: widget.email);
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
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    _resendEmailCount++;
    _startResendTimer();
  }

  /// Start the resend email timer
  ///
  /// This function starts the resend email timer and updates the UI
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
