import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/campaign/data/collaboration_repository.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/collaboration.dart';
import 'package:flutter/material.dart';

class AcceptCollaboration extends CollaborationEvent {
  final String collaborationId;
  AcceptCollaboration(this.collaborationId);
}

class BrandCollaborationsLoaded extends CollaborationState {
  final List<Collaboration> collaborations;
  BrandCollaborationsLoaded(this.collaborations);
}

class CampaignCollaborationsLoaded extends CollaborationState {
  final List<Collaboration> collaborations;
  CampaignCollaborationsLoaded(this.collaborations);
}

class CollaborationAccepted extends CollaborationState {
  final Collaboration collaboration;
  CollaborationAccepted(this.collaboration);
}

// Bloc
class CollaborationBloc extends Bloc<CollaborationEvent, CollaborationState> {
  CollaborationBloc() : super(CollaborationInitial()) {
    // Load collaborations created by the brand
    on<LoadBrandCollaborations>((event, emit) async {
      emit(CollaborationsLoading());
      try {
        final collaborations =
            await CollaborationRepository.getBrandCollaborations();
        emit(BrandCollaborationsLoaded(collaborations));
      } catch (e) {
        debugPrint('Error loading brand collaborations: $e');
        final errorRepo = ErrorRepository();
        emit(CollaborationError(errorRepo.handleError(e)));
      }
    });

    // Load collaborations sent to the influencer
    on<LoadInfluencerCollaborations>((event, emit) async {
      emit(CollaborationsLoading());
      try {
        final collaborations =
            await CollaborationRepository.getInfluencerCollaborations();
        emit(InfluencerCollaborationsLoaded(collaborations));
      } catch (e) {
        debugPrint('Error loading influencer collaborations: $e');
        final errorRepo = ErrorRepository();
        emit(CollaborationError(errorRepo.handleError(e)));
      }
    });

    // Load collaborations for a specific campaign
    on<LoadCampaignCollaborations>((event, emit) async {
      emit(CollaborationsLoading());
      try {
        final collaborations =
            await CollaborationRepository.getCampaignCollaborations(
                event.campaignId);
        emit(CampaignCollaborationsLoaded(collaborations));
      } catch (e) {
        debugPrint('Error loading campaign collaborations: $e');
        final errorRepo = ErrorRepository();
        emit(CollaborationError(errorRepo.handleError(e)));
      }
    });

    // Create a new collaboration request
    on<CreateCollaboration>((event, emit) async {
      emit(CollaborationsLoading());
      try {
        final collaboration = await CollaborationRepository.createCollaboration(
          event.campaignId,
          event.influencerId,
          event.proposedAmount,
          event.message,
        );
        emit(CollaborationCreated(collaboration));
      } catch (e) {
        debugPrint('Error creating collaboration: $e');
        final errorRepo = ErrorRepository();
        emit(CollaborationError(errorRepo.handleError(e)));
      }
    });

    // Accept a collaboration request
    on<AcceptCollaboration>((event, emit) async {
      emit(CollaborationsLoading());
      try {
        final collaboration = await CollaborationRepository.acceptCollaboration(
            event.collaborationId);
        emit(CollaborationAccepted(collaboration));
      } catch (e) {
        debugPrint('Error accepting collaboration: $e');
        final errorRepo = ErrorRepository();
        emit(CollaborationError(errorRepo.handleError(e)));
      }
    });

    // Reject a collaboration request
    on<RejectCollaboration>((event, emit) async {
      emit(CollaborationsLoading());
      try {
        final collaboration = await CollaborationRepository.rejectCollaboration(
            event.collaborationId);
        emit(CollaborationRejected(collaboration));
      } catch (e) {
        debugPrint('Error rejecting collaboration: $e');
        final errorRepo = ErrorRepository();
        emit(CollaborationError(errorRepo.handleError(e)));
      }
    });

    // Counter offer to a collaboration
    on<CounterOfferCollaboration>((event, emit) async {
      emit(CollaborationsLoading());
      try {
        final collaboration =
            await CollaborationRepository.counterOfferCollaboration(
          event.collaborationId,
          event.counterAmount,
          event.message,
        );
        emit(CollaborationCounterOffered(collaboration));
      } catch (e) {
        debugPrint('Error making counter offer: $e');
        final errorRepo = ErrorRepository();
        emit(CollaborationError(errorRepo.handleError(e)));
      }
    });
  }
}

class CollaborationCounterOffered extends CollaborationState {
  final Collaboration collaboration;
  CollaborationCounterOffered(this.collaboration);
}

class CollaborationCreated extends CollaborationState {
  final Collaboration collaboration;
  CollaborationCreated(this.collaboration);
}

class CollaborationError extends CollaborationState {
  final String message;
  CollaborationError(this.message);
}

// Events
abstract class CollaborationEvent {}

class CollaborationInitial extends CollaborationState {}

class CollaborationRejected extends CollaborationState {
  final Collaboration collaboration;
  CollaborationRejected(this.collaboration);
}

class CollaborationsLoading extends CollaborationState {}

// States
abstract class CollaborationState {}

class CounterOfferCollaboration extends CollaborationEvent {
  final String collaborationId;
  final double counterAmount;
  final String message;

  CounterOfferCollaboration({
    required this.collaborationId,
    required this.counterAmount,
    required this.message,
  });
}

class CreateCollaboration extends CollaborationEvent {
  final String campaignId;
  final String influencerId;
  final double proposedAmount;
  final String message;

  CreateCollaboration({
    required this.campaignId,
    required this.influencerId,
    required this.proposedAmount,
    required this.message,
  });
}

class InfluencerCollaborationsLoaded extends CollaborationState {
  final List<Collaboration> collaborations;
  InfluencerCollaborationsLoaded(this.collaborations);
}

class LoadBrandCollaborations extends CollaborationEvent {}

class LoadCampaignCollaborations extends CollaborationEvent {
  final String campaignId;
  LoadCampaignCollaborations(this.campaignId);
}

class LoadInfluencerCollaborations extends CollaborationEvent {}

class RejectCollaboration extends CollaborationEvent {
  final String collaborationId;
  RejectCollaboration(this.collaborationId);
}
