import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../common/domain/repositories/error_repository.dart';
import '../../../../../common/models/influencers.dart';
import '../../../common/data/dashboard_repo.dart';

part 'brand_dashboard_event.dart';
part 'brand_dashboard_state.dart';

class BrandDashboardBloc
    extends Bloc<BrandDashboardEvent, BrandDashboardState> {
  int page = 0;
  BrandDashboardBloc() : super(BrandDashboardInitial()) {
    on<BrandDashboardLoadInfluencers>((event, emit) async {
      if (state is BrandDashboardLoadedInfluencers) {
        return;
      }
      emit(BrandDashboardLoadingInfluencers());
      try {
        final influencers = await DashboardRepo.getInfluencersList();
        emit(BrandDashboardLoadedInfluencers(influencers));
        page++;
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        throw errorRepo.handleError(e);
      }
    });
  }
}
