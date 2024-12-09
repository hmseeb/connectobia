import 'package:bloc/bloc.dart';
import 'package:connectobia/common/models/brand_profile.dart';
import 'package:connectobia/modules/auth/domain/model/brand.dart';
import 'package:connectobia/modules/dashboard/common/influencer_repo.dart';
import 'package:meta/meta.dart';

part 'brand_profile_event.dart';
part 'brand_profile_state.dart';

class BrandProfileBloc extends Bloc<BrandProfileEvent, BrandProfileState> {
  BrandProfileBloc() : super(BrandProfileInitial()) {
    on<LoadBrandProfile>((event, emit) async {
      emit(BrandProfileLoading());
      try {
        final BrandProfile brandProfile =
            await SearchRepo.getBrandProfile(profileId: event.profileId);
        emit(
            BrandProfileLoaded(brand: event.brand, brandProfile: brandProfile));
      } catch (e) {
        throw Exception(e);
      }
    });
  }
}
