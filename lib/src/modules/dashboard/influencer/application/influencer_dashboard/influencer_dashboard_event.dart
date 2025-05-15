part of 'influencer_dashboard_bloc.dart';

class FilterBrands extends InfluencerDashboardEvent {
  final String filter;

  FilterBrands(this.filter);
}

/// Event to toggle favorite filter
class FilterFavoriteBrands extends InfluencerDashboardEvent {
  final bool showOnlyFavorites;
  final String userId;

  FilterFavoriteBrands({
    required this.showOnlyFavorites,
    required this.userId,
  });
}

@immutable
sealed class InfluencerDashboardEvent {}

class InfluencerDashboardLoadBrands extends InfluencerDashboardEvent {}
