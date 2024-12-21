part of 'influencer_dashboard_bloc.dart';

@immutable
sealed class InfluencerDashboardState {}

final class InfluencerDashboardInitial extends InfluencerDashboardState {}

final class InfluencerDashboardLoadingBrands extends InfluencerDashboardState {}

final class InfluencerDashboardLoadedBrands extends InfluencerDashboardState {
  final Brands brands;
  InfluencerDashboardLoadedBrands(this.brands);
}
