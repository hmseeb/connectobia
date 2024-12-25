import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../shared/data/repositories/error_repo.dart';
import '../../../../../shared/domain/models/brands.dart';
import '../../../common/data/repositories/dashboard_repo.dart';

part 'influencer_dashboard_event.dart';
part 'influencer_dashboard_state.dart';

class InfluencerDashboardBloc
    extends Bloc<InfluencerDashboardEvent, InfluencerDashboardState> {
  Brands? brands;
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
  }
}
