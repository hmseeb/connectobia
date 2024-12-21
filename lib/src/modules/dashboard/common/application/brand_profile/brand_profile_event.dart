part of 'brand_profile_bloc.dart';

@immutable
sealed class BrandProfileEvent {}

class LoadBrandProfile extends BrandProfileEvent {
  final String profileId;
  final Brand brand;

  LoadBrandProfile({required this.profileId, required this.brand});
}
