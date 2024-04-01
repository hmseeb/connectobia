import 'package:bloc/bloc.dart';
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
            await ContractRepository.getContractForCampaign(event.campaignId);
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
        final contract = await ContractRepository.createContract(
          event.campaignId,
          event.influencerId,
          event.postTypes,
          event.deliveryDate,
          event.payout,
          event.terms,
        );
        emit(ContractCreated(contract));
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
            await ContractRepository.signContractByInfluencer(event.contractId);
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
        final contract =
            await ContractRepository.rejectContract(event.contractId);
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
        final contract =
            await ContractRepository.completeContract(event.contractId);
        emit(ContractCompleted(contract));
      } catch (e) {
        debugPrint('Error completing contract: $e');
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

class CreateContract extends ContractEvent {
  final String campaignId;
  final String influencerId;
  final List<String> postTypes;
  final DateTime deliveryDate;
  final double payout;
  final String terms;

  CreateContract({
    required this.campaignId,
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
