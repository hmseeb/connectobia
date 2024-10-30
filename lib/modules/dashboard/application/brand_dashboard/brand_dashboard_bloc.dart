import 'package:bloc/bloc.dart';
import 'package:connectobia/modules/dashboard/application/domain/user_list.dart';
import 'package:connectobia/modules/dashboard/data/dashboard_repo.dart';
import 'package:meta/meta.dart';

part 'brand_dashboard_event.dart';
part 'brand_dashboard_state.dart';

class BrandDashboardBloc
    extends Bloc<BrandDashboardEvent, BrandDashboardState> {
  BrandDashboardBloc() : super(BrandDashboardInitial()) {
    on<BrandDashboardLoadInfluencers>((event, emit) async {
      emit(BrandDashboardLoadingInflueners());
      final influencers = await DashboardRepo.getUserList();
      emit(BrandDashboardLoadedInflueners(influencers));
    });
  }
}
