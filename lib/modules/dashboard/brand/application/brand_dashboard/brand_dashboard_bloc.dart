import 'package:bloc/bloc.dart';
import 'package:connectobia/common/models/influencers.dart';
import 'package:connectobia/modules/dashboard/common/data/dashboard_repo.dart';
import 'package:meta/meta.dart';

part 'brand_dashboard_event.dart';
part 'brand_dashboard_state.dart';

class BrandDashboardBloc
    extends Bloc<BrandDashboardEvent, BrandDashboardState> {
  int page = 0;
  BrandDashboardBloc() : super(BrandDashboardInitial()) {
    on<BrandDashboardLoadInfluencers>((event, emit) async {
      emit(BrandDashboardLoadingInfluencers());
      try {
        final influencers = await DashboardRepo.getInfluencersList();
        emit(BrandDashboardLoadedInfluencers(influencers));
        page++;
      } catch (e) {
        throw Exception(e);
      }
    });
  }
}
