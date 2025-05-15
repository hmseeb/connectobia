part of 'brand_dashboard_bloc.dart';

/// Advanced filtering event with multiple criteria
class AdvancedFilterInfluencers extends BrandDashboardEvent {
  /// Text search filter (name, industry)
  final String textFilter;

  /// Map of filter names to range values for numeric filters
  /// Keys include: followers, engRate, mediaCount, etc.
  final Map<String, RangeValues> rangeFilters;

  AdvancedFilterInfluencers({
    this.textFilter = '',
    required this.rangeFilters,
  });
}

@immutable
sealed class BrandDashboardEvent {}

class BrandDashboardLoadInfluencers extends BrandDashboardEvent {}

/// Event to filter influencers by favorite status
class FilterFavoriteInfluencers extends BrandDashboardEvent {
  /// Whether to only show favorites
  final bool showOnlyFavorites;

  /// Current user ID needed to check favorites
  final String userId;

  FilterFavoriteInfluencers({
    required this.showOnlyFavorites,
    required this.userId,
  });
}

class FilterInfluencers extends BrandDashboardEvent {
  final String filter;
  FilterInfluencers({required this.filter});
}
