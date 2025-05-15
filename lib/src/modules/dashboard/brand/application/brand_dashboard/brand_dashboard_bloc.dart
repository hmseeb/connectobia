import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show RangeValues;

import '../../../../../modules/profile/data/favorites_repository.dart';
import '../../../../../shared/data/repositories/error_repo.dart';
import '../../../../../shared/domain/models/influencers.dart';
import '../../../common/data/repositories/dashboard_repo.dart';

part 'brand_dashboard_event.dart';
part 'brand_dashboard_state.dart';

class BrandDashboardBloc
    extends Bloc<BrandDashboardEvent, BrandDashboardState> {
  Influencers? influencers;
  int page = 0;
  bool _showOnlyFavorites = false;

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

    on<FilterFavoriteInfluencers>((event, emit) async {
      if (state is BrandDashboardLoadedInfluencers && influencers != null) {
        emit(BrandDashboardLoadingInfluencers());

        try {
          _showOnlyFavorites = event.showOnlyFavorites;

          if (_showOnlyFavorites) {
            // Get the list of favorite influencer IDs
            final favoriteIds =
                await FavoritesRepository.getUserFavoriteIds(event.userId);

            // Filter the influencers list to only show favorites
            final filteredInfluencers = influencers!.filterByIds(favoriteIds);
            emit(BrandDashboardLoadedInfluencers(filteredInfluencers));
          } else {
            // Show all influencers if favorites filter is turned off
            emit(BrandDashboardLoadedInfluencers(influencers!));
          }
        } catch (e) {
          debugPrint('Error filtering favorites: $e');
          // Fall back to the original list if there's an error
          emit(BrandDashboardLoadedInfluencers(influencers!));
        }
      }
    });

    on<AdvancedFilterInfluencers>((event, emit) async {
      if (state is BrandDashboardLoadedInfluencers && influencers != null) {
        // First show temporary results with just the text filter
        final preliminaryResults = influencers!.advancedFilterInfluencers(
          textFilter: event.textFilter,
          rangeFilters: event.rangeFilters,
        );

        // Only show loading state if we have range filters
        if (event.rangeFilters.isNotEmpty) {
          emit(BrandDashboardLoadingInfluencers());
        } else {
          emit(BrandDashboardLoadedInfluencers(preliminaryResults));
          return;
        }

        try {
          // Now load the profiles and apply full filtering
          final filteredInfluencers =
              await Influencers.advancedFilterWithProfiles(
            source: influencers!,
            textFilter: event.textFilter,
            rangeFilters: event.rangeFilters,
          );

          emit(BrandDashboardLoadedInfluencers(filteredInfluencers));
        } catch (e) {
          debugPrint('Error during advanced filtering: $e');
          // Fall back to the preliminary results if there's an error
          emit(BrandDashboardLoadedInfluencers(preliminaryResults));
        }
      }
    });
  }

  // Getter for favorite filter state
  bool get showOnlyFavorites => _showOnlyFavorites;
}
