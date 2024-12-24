part of 'brand_profile_bloc.dart';

class BrandProfileError extends BrandProfileState {
  final String message;

  BrandProfileError(this.message);
}

final class BrandProfileInitial extends BrandProfileState {}

class BrandProfileLoaded extends BrandProfileState {
  final Brand brand;
  final BrandProfile brandProfile;
  final bool isInfluencerVerified;

  BrandProfileLoaded(
      {required this.brand,
      required this.brandProfile,
      required this.isInfluencerVerified});
}

class BrandProfileLoading extends BrandProfileState {}

@immutable
sealed class BrandProfileState {}
