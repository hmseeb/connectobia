part of 'influencer_dashboard_bloc.dart';

class FilterBrands extends InfluencerDashboardEvent {
  final String filter;
  FilterBrands({required this.filter});
}

@immutable
sealed class InfluencerDashboardEvent {}

class InfluencerDashboardLoadBrands extends InfluencerDashboardEvent {}
