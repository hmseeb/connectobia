import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  CampaignBloc() : super(CampaignInitial()) {
    // Event to load campaigns
    on<LoadCampaigns>((event, emit) async {
      emit(CampaignsLoading());
      try {
        List<Campaign> campaigns = await CampaignRepository.getCampaigns();
        emit(CampaignsLoaded(campaigns));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(CampaignsLoadingError(errorRepo.handleError(e)));
      }
    });

    // Event to search campaigns
    on<SearchCampaigns>((event, emit) async {
      emit(CampaignsLoading());
      try {
        List<Campaign> campaigns = await CampaignRepository.getCampaigns();
        final filteredCampaigns = campaigns
            .where((campaign) => campaign.title
                .toLowerCase()
                .contains(event.query.toLowerCase()))
            .toList();
        emit(CampaignsLoaded(filteredCampaigns));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(CampaignsLoadingError(errorRepo.handleError(e)));
      }
    });
  }
}
