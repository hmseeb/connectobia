import 'dart:async';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../services/storage/pb.dart';
import '../../../../shared/data/constants/screens.dart';
import '../../../../theme/colors.dart';
import '../../application/verification/email_verification_bloc.dart';
import '../../data/repositories/auth_repo.dart';
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
    return BlocListener<EmailVerificationBloc, EmailVerificationState>(
      listener: (context, state) {
        if (state is BrandEmailVerified) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              brandDashboard, (route) => false,
              arguments: {
                'user': state.brand,
              });
        } else if (state is InfluencerEmailVerified) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              influencerDashboard, (route) => false,
              arguments: {
                'user': state.influencer,
              });
        } else if (state is EmailVerificationError) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: Text(state.error),
            ),
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
                CircleAvatar(
                  radius: 50,
                  backgroundColor: ShadColors.primary.withAlpha(200),
                  child: const Icon(
                    LucideIcons.mail,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
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
                // open email button using url launcher
                SizedBox(
                  width: double.infinity,
                  child: ShadButton(
                    onPressed: () async {
                      await openEmailApp(context);
                    },
                    child: const Text('Open Email App'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: _canResendEmail
                          ? () {
                              _resendEmail(context);
                            }
                          : null,
                      child: Text(
                        isLoading
                            ? 'Resending code...'
                            : _canResendEmail
                                ? 'Resend code'
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
                    GestureDetector(
                      onTap: () {
                        _changeEmail();
                      },
                      child: Text(
                        'Change email',
                        style: TextStyle(
                            color: ShadColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
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
  Future<void> openEmailApp(BuildContext context) async {
    try {
      // Android: Will open mail app or show native picker.
      // iOS: Will open mail app if single mail app found.
      bool isInstalled = await LaunchApp.isAppInstalled(
        iosUrlScheme: 'message://',
        androidPackageName: 'com.google.android.gm',
      );

      if (isInstalled) {
        await LaunchApp.openApp(
          iosUrlScheme: 'message://',
          androidPackageName: 'com.google.android.gm',
        );
      } else {
        if (context.mounted) {
          showShadDialog(
            context: context,
            builder: (context) => ShadDialog.alert(
              title: const Text('There is no mail app installed'),
              actions: [
                ShadButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Show error toast
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: Text(e.toString()),
          ),
        );
      }
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

  void _changeEmail() async {
    Navigator.pushNamedAndRemoveUntil(context, welcomeScreen, (route) => false);
    await AuthRepository.logout();
  }

  /// Resend the verification email
  ///
  /// This function resend the verification email to the user's email address.
  void _resendEmail(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      await AuthRepository.verifyEmail(email: widget.email);
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
