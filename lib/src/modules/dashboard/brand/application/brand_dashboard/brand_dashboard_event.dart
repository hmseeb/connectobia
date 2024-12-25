part of 'brand_dashboard_bloc.dart';

@immutable
sealed class BrandDashboardEvent {}

class BrandDashboardLoadInfluencers extends BrandDashboardEvent {}

class FilterInfluencers extends BrandDashboardEvent {
  final String filter;
  FilterInfluencers({required this.filter});
}
