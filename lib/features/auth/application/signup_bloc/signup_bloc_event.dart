part of 'signup_bloc_bloc.dart';

final class AccountTypeChangedEvent extends SignupBlocEvent {
  final String accountType;
  AccountTypeChangedEvent(this.accountType);
}

final class EmailChangedEvent extends SignupBlocEvent {
  final String email;
  EmailChangedEvent(this.email);
}

final class FirstNameChangedEvent extends SignupBlocEvent {
  final String firstName;
  FirstNameChangedEvent(this.firstName);
}

final class LastNameChangedEvent extends SignupBlocEvent {
  final String lastName;
  LastNameChangedEvent(this.lastName);
}

final class PasswordChangedEvent extends SignupBlocEvent {
  final String password;
  PasswordChangedEvent(this.password);
}

@immutable
sealed class SignupBlocEvent {}

final class SubmittedEvent extends SignupBlocEvent {
  SubmittedEvent();
}

final class WebsiteChangedEvent extends SignupBlocEvent {
  final String website;
  WebsiteChangedEvent(this.website);
}
