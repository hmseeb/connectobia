part of 'signup_bloc.dart';

class InstagramSignup extends SignupEvent {
  InstagramSignup();
}

class SignupBrandSubmitted extends SignupEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String brandName;
  final String password;
  final String accountType = 'brand';
  final String industry;

  SignupBrandSubmitted({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.brandName,
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
