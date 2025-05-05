import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart' show RangeValues;
import 'package:meta/meta.dart';

import '../../../../../shared/data/repositories/error_repo.dart';
import '../../../../../shared/domain/models/influencers.dart';
import '../../../common/data/repositories/dashboard_repo.dart';

part 'brand_dashboard_event.dart';
part 'brand_dashboard_state.dart';

class BrandDashboardBloc
    extends Bloc<BrandDashboardEvent, BrandDashboardState> {
  Influencers? influencers;
  int page = 0;
  BrandDashboardBloc() : super(BrandDashboardInitial()) {
    on<BrandDashboardLoadInfluencers>((event, emit) async {
      if (state is BrandDashboardLoadedInfluencers) {
        return;
      }
      emit(BrandDashboardLoadingInfluencers());
      try {
        influencers = await DashboardRepository.getInfluencersList();
        emit(BrandDashboardLoadedInfluencers(influencers!));
        page++;
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });

    on<FilterInfluencers>((event, emit) async {
      if (state is BrandDashboardLoadedInfluencers) {
        final filteredInfluencers =
            influencers!.filterInfluencers(event.filter);
        emit(BrandDashboardLoadedInfluencers(filteredInfluencers));
      }
    });

    on<AdvancedFilterInfluencers>((event, emit) async {
      if (state is BrandDashboardLoadedInfluencers && influencers != null) {
        // Use the enhanced filtering method
        final filteredInfluencers = influencers!.advancedFilterInfluencers(
          textFilter: event.textFilter,
          followerRange: event.followerRange,
          engagementRange: event.engagementRange,
          country: event.country,
          gender: event.gender,
        );

        emit(BrandDashboardLoadedInfluencers(filteredInfluencers));
      }
    });
  }
}
