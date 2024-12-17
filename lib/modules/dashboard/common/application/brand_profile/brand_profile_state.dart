part of 'brand_profile_bloc.dart';

@immutable
sealed class BrandProfileState {}

final class BrandProfileInitial extends BrandProfileState {}

class BrandProfileLoading extends BrandProfileState {}

class BrandProfileLoaded extends BrandProfileState {
  final Brand brand;
  final BrandProfile brandProfile;

  BrandProfileLoaded({required this.brand, required this.brandProfile});
}

class BrandProfileError extends BrandProfileState {
  final String message;

  BrandProfileError(this.message);
}
