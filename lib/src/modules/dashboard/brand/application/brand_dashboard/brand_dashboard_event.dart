part of 'brand_dashboard_bloc.dart';

/// Advanced filtering event with multiple criteria
class AdvancedFilterInfluencers extends BrandDashboardEvent {
  /// Text search filter (name, industry)
  final String textFilter;

  /// Follower count range (min, max)
  final RangeValues? followerRange;

  /// Engagement rate range (min, max)
  final RangeValues? engagementRange;

  /// Country filter
  final String? country;

  /// Gender filter
  final String? gender;

  AdvancedFilterInfluencers({
    this.textFilter = '',
    this.followerRange,
    this.engagementRange,
    this.country,
    this.gender,
  });
}

@immutable
sealed class BrandDashboardEvent {}

class BrandDashboardLoadInfluencers extends BrandDashboardEvent {}

class FilterInfluencers extends BrandDashboardEvent {
  final String filter;
  FilterInfluencers({required this.filter});
}
