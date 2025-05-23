import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:connectobia/src/modules/campaign/data/contract_repository.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/contract.dart';
import 'package:flutter/material.dart';

class BrandContractsLoaded extends ContractState {
  final List<Contract> contracts;
  BrandContractsLoaded(this.contracts);
}

class CampaignContractLoaded extends ContractState {
  final Contract? contract;
  CampaignContractLoaded(this.contract);
}

class CompleteContract extends ContractEvent {
  final String contractId;
  CompleteContract(this.contractId);
}

// Bloc
class ContractBloc extends Bloc<ContractEvent, ContractState> {
  ContractBloc() : super(ContractInitial()) {
    // Load contracts created by the brand
    on<LoadBrandContracts>((event, emit) async {
      emit(ContractsLoading());
      try {
        final contracts = await ContractRepository.getBrandContracts();
        emit(BrandContractsLoaded(contracts));
      } catch (e) {
        debugPrint('Error loading brand contracts: $e');
        final errorRepo = ErrorRepository();
        emit(ContractError(errorRepo.handleError(e)));
      }
    });

    // Load contracts sent to the influencer
    on<LoadInfluencerContracts>((event, emit) async {
      emit(ContractsLoading());
      try {
        final contracts = await ContractRepository.getInfluencerContracts();
        emit(InfluencerContractsLoaded(contracts));
      } catch (e) {
        debugPrint('Error loading influencer contracts: $e');
        final errorRepo = ErrorRepository();
        emit(ContractError(errorRepo.handleError(e)));
      }
    });

    // Load contract for a specific campaign
    on<LoadCampaignContract>((event, emit) async {
      emit(ContractsLoading());
      try {
        final contract =
            await ContractRepository.getContractByCampaignId(event.campaignId);
        emit(CampaignContractLoaded(contract));
      } catch (e) {
        debugPrint('Error loading campaign contract: $e');
        final errorRepo = ErrorRepository();
        emit(ContractError(errorRepo.handleError(e)));
      }
    });

    // Create a new contract
    on<CreateContract>((event, emit) async {
      emit(ContractsLoading());
      try {
        // Create a Contract object from the event data
        final contract = Contract(
          id: '', // Will be set by database
          campaign: event.campaignId,
          brand: event.brandId,
          influencer: event.influencerId,
          postType: event.postTypes,
          deliveryDate: event.deliveryDate,
          payout: event.payout,
          terms: event.terms,
          isSignedByBrand: true,
          isSignedByInfluencer: false,
          status: 'pending',
        );

        final createdContract =
            await ContractRepository.createContract(contract);
        emit(ContractCreated(createdContract));
      } catch (e) {
        debugPrint('Error creating contract: $e');
        final errorRepo = ErrorRepository();
        emit(ContractError(errorRepo.handleError(e)));
      }
    });

    // Sign a contract by influencer
    on<SignContractByInfluencer>((event, emit) async {
      emit(ContractsLoading());
      try {
        final contract =
            await ContractRepository.signByInfluencer(event.contractId);
        emit(ContractSigned(contract));
      } catch (e) {
        debugPrint('Error signing contract: $e');
        final errorRepo = ErrorRepository();
        emit(ContractError(errorRepo.handleError(e)));
      }
    });

    // Reject a contract
    on<RejectContract>((event, emit) async {
      emit(ContractsLoading());
      try {
        debugPrint('Rejecting contract: ${event.contractId}');
        final contract =
            await ContractRepository.rejectByInfluencer(event.contractId);
        debugPrint(
            'Contract rejected successfully with status: ${contract.status}');

        // Make sure campaign status is updated in backend
        try {
          await CampaignRepository.updateCampaignStatus(
              contract.campaign, 'rejected');
          debugPrint('Campaign status updated to rejected');
        } catch (e) {
          debugPrint(
              'Error updating campaign status after contract rejection: $e');
          // Don't fail the whole operation if just this part fails
        }

        emit(ContractRejected(contract));
      } catch (e) {
        debugPrint('Error rejecting contract: $e');
        final errorRepo = ErrorRepository();
        emit(ContractError(errorRepo.handleError(e)));
      }
    });

    // Complete a contract
    on<CompleteContract>((event, emit) async {
      emit(ContractsLoading());
      try {
        final contract = await ContractRepository.updateStatus(
            event.contractId, 'completed');
        emit(ContractCompleted(contract));
      } catch (e) {
        debugPrint('Error completing contract: $e');
        final errorRepo = ErrorRepository();
        emit(ContractError(errorRepo.handleError(e)));
      }
    });

    // Update post URLs
    on<UpdateContractPostUrls>((event, emit) async {
      emit(ContractsLoading());
      try {
        final contract = await ContractRepository.updatePostUrls(
            event.contractId, event.postUrlJson);
        emit(ContractUrlsUpdated(contract));
      } catch (e) {
        debugPrint('Error updating post URLs: $e');
        final errorRepo = ErrorRepository();
        emit(ContractError(errorRepo.handleError(e)));
      }
    });
  }
}

class ContractCompleted extends ContractState {
  final Contract contract;
  ContractCompleted(this.contract);
}

class ContractCreated extends ContractState {
  final Contract contract;
  ContractCreated(this.contract);
}

class ContractError extends ContractState {
  final String message;
  ContractError(this.message);
}

// Events
abstract class ContractEvent {}

class ContractInitial extends ContractState {}

class ContractRejected extends ContractState {
  final Contract contract;
  ContractRejected(this.contract);
}

class ContractSigned extends ContractState {
  final Contract contract;
  ContractSigned(this.contract);
}

class ContractsLoading extends ContractState {}

// States
abstract class ContractState {}

class ContractUrlsUpdated extends ContractState {
  final Contract contract;
  ContractUrlsUpdated(this.contract);
}

class CreateContract extends ContractEvent {
  final String campaignId;
  final String brandId;
  final String influencerId;
  final List<String> postTypes;
  final DateTime deliveryDate;
  final double payout;
  final String terms;

  CreateContract({
    required this.campaignId,
    required this.brandId,
    required this.influencerId,
    required this.postTypes,
    required this.deliveryDate,
    required this.payout,
    required this.terms,
  });
}

class InfluencerContractsLoaded extends ContractState {
  final List<Contract> contracts;
  InfluencerContractsLoaded(this.contracts);
}

class LoadBrandContracts extends ContractEvent {}

class LoadCampaignContract extends ContractEvent {
  final String campaignId;
  LoadCampaignContract(this.campaignId);
}

class LoadInfluencerContracts extends ContractEvent {}

class RejectContract extends ContractEvent {
  final String contractId;
  RejectContract(this.contractId);
}

class SignContractByInfluencer extends ContractEvent {
  final String contractId;
  SignContractByInfluencer(this.contractId);
}

class UpdateContractPostUrls extends ContractEvent {
  final String contractId;
  final String postUrlJson;

  UpdateContractPostUrls(this.contractId, this.postUrlJson);
}
