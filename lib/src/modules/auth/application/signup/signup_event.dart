part of 'signup_bloc.dart';

class SignupBrandSubmitted extends SignupEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String? website;
  final String password;
  final String accountType = 'brand';

  SignupBrandSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.website,
    required this.password,
  });
}

@immutable
sealed class SignupEvent {}

class SignupInfluencerSubmitted extends SignupEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  SignupInfluencerSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}
