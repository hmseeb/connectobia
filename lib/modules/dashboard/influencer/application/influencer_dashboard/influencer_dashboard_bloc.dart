import 'package:bloc/bloc.dart';
import 'package:connectobia/common/models/brands.dart';
import 'package:connectobia/modules/dashboard/common/data/dashboard_repo.dart';
import 'package:meta/meta.dart';

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
        throw Exception(e);
      }
    });
  }
}
