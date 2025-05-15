import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../../../../modules/profile/data/favorites_repository.dart';
import '../../../../../shared/data/repositories/error_repo.dart';
import '../../../../../shared/domain/models/brands.dart';
import '../../../common/data/repositories/dashboard_repo.dart';

part 'influencer_dashboard_event.dart';
part 'influencer_dashboard_state.dart';

class InfluencerDashboardBloc
    extends Bloc<InfluencerDashboardEvent, InfluencerDashboardState> {
  Brands? brands;
  bool _showOnlyFavorites = false;

  InfluencerDashboardBloc() : super(InfluencerDashboardInitial()) {
    on<InfluencerDashboardLoadBrands>((event, emit) async {
      if (state is InfluencerDashboardLoadedBrands) {
        return;
      }
      emit((InfluencerDashboardLoadingBrands()));
      try {
        brands = await DashboardRepository.getBrandsList();
        emit(InfluencerDashboardLoadedBrands(brands!));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();

        throw errorRepo.handleError(e);
      }
    });

    on<FilterBrands>((event, emit) async {
      if (state is InfluencerDashboardLoadedBrands) {
        final filteredBrands = brands!.filterBrands(event.filter);
        emit(InfluencerDashboardLoadedBrands(filteredBrands));
      }
    });

    on<FilterFavoriteBrands>((event, emit) async {
      if (state is InfluencerDashboardLoadedBrands && brands != null) {
        emit(InfluencerDashboardLoadingBrands());

        try {
          _showOnlyFavorites = event.showOnlyFavorites;

          if (_showOnlyFavorites) {
            // Get the list of favorite brand IDs
            final favoriteIds =
                await FavoritesRepository.getUserFavoriteIds(event.userId);

            // Filter the brands list to only show favorites
            final filteredBrands = brands!.filterByIds(favoriteIds);
            emit(InfluencerDashboardLoadedBrands(filteredBrands));
          } else {
            // Show all brands if favorites filter is turned off
            emit(InfluencerDashboardLoadedBrands(brands!));
          }
        } catch (e) {
          debugPrint('Error filtering favorites: $e');
          // Fall back to the original list if there's an error
          emit(InfluencerDashboardLoadedBrands(brands!));
        }
      }
    });
  }

  // Getter for favorite filter state
  bool get showOnlyFavorites => _showOnlyFavorites;
}
