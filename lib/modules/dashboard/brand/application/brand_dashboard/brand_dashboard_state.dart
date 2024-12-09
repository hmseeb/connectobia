part of 'brand_dashboard_bloc.dart';

final class BrandDashboardInitial extends BrandDashboardState {}

final class BrandDashboardLoadedInflueners extends BrandDashboardState {
  final Influencers influencers;
  BrandDashboardLoadedInflueners(this.influencers);
}

final class BrandDashboardLoadingInflueners extends BrandDashboardState {}

final class BrandDashboardLoadingMoreInflueners extends BrandDashboardState {}

@immutable
sealed class BrandDashboardState {}
