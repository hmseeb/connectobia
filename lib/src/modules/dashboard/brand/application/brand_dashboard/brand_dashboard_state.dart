part of 'brand_dashboard_bloc.dart';

final class BrandDashboardInitial extends BrandDashboardState {}

final class BrandDashboardLoadedInfluencers extends BrandDashboardState {
  final Influencers influencers;
  BrandDashboardLoadedInfluencers(this.influencers);
}

final class BrandDashboardLoadingInfluencers extends BrandDashboardState {}

final class BrandDashboardLoadingMoreInfluencers extends BrandDashboardState {}

@immutable
sealed class BrandDashboardState {}
