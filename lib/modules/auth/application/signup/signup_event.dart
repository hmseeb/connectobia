part of 'signup_bloc.dart';

class InstagramSignup extends SignupEvent {
  final String accountType;
  InstagramSignup({required this.accountType});
}

class SignupBrandSubmitted extends SignupEvent {
  final String brandName;
  final String username;
  final String email;
  final String password;
  final String industry;

  SignupBrandSubmitted({
    required this.brandName,
    required this.username,
    required this.email,
    required this.password,
    required this.industry,
  });
}

@immutable
sealed class SignupEvent {}

class SignupInfluencerSubmitted extends SignupEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String industry;

  SignupInfluencerSubmitted({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.industry,
  });
}
