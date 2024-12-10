import 'package:bloc/bloc.dart';
import 'package:connectobia/common/domain/repositories/error_repository.dart';
import 'package:meta/meta.dart';

import '../../../../../common/models/brands.dart';
import '../../../common/data/dashboard_repo.dart';

part 'influencer_dashboard_event.dart';
part 'influencer_dashboard_state.dart';

class InfluencerDashboardBloc
    extends Bloc<InfluencerDashboardEvent, InfluencerDashboardState> {
  InfluencerDashboardBloc() : super(InfluencerDashboardInitial()) {
    on<InfluencerDashboardLoadBrands>((event, emit) async {
      emit((InfluencerDashboardLoadingBrands()));
      try {
        final Brands brands = await DashboardRepo.getBrandsList();
        emit(InfluencerDashboardLoadedBrands(brands));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });
  }
}
