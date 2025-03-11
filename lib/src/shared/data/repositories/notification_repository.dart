import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:flutter/material.dart';

/// Repository for handling notifications
class NotificationRepository {
  static const String _collectionName = 'notifications';

  /// Create a campaign notification
  static Future<void> createCampaignNotification({
    required String userId,
    required String campaignTitle,
    required String campaignId,
  }) async {
    await createNotification(
      userId: userId,
      title: 'New Campaign Contract',
      body: 'You have received a new contract for the campaign: $campaignTitle',
      type: 'campaign',
      redirectUrl: '/campaign/$campaignId',
    );
  }

  /// Create a contract notification
  static Future<void> createContractNotification({
    required String userId,
    required String contractId,
    required String campaignTitle,
  }) async {
    await createNotification(
      userId: userId,
      title: 'Contract Created',
      body: 'A contract has been created for campaign: $campaignTitle',
      type: 'contract',
      redirectUrl: '/contract/$contractId',
    );
  }

  /// Create a contract signed notification for the brand
  static Future<void> createContractSignedNotification({
    required String brandId,
    required String influencerName,
    required String contractId,
    required String campaignTitle,
  }) async {
    await createNotification(
      userId: brandId,
      title: 'Contract Signed',
      body:
          '$influencerName has signed the contract for campaign: $campaignTitle',
      type: 'contract_signed',
      redirectUrl: '/contract/$contractId',
    );
  }

  /// Create a new notification
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? redirectUrl,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      debugPrint('Creating notification for user $userId: $title');

      final notificationData = {
        'user': userId,
        'title': title,
        'body': body,
        'type': type,
        'read': false,
        'redirect_url': redirectUrl ?? '',
      };

      await pb.collection(_collectionName).create(body: notificationData);

      debugPrint('Notification created successfully');
    } catch (e) {
      debugPrint('Error creating notification: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
