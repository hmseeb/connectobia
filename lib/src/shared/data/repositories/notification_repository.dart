import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/models/notification.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

/// Repository for handling notifications
class NotificationRepository {
  static const String _collectionName = 'notifications';

  /// Allowed notification types
  static const List<String> allowedTypes = [
    'campaign',
    'contract',
    'content',
    'payment',
    'system'
  ];

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

  /// Create a content notification
  static Future<void> createContentNotification({
    required String userId,
    required String title,
    required String body,
    String? redirectUrl,
  }) async {
    await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: 'content',
      redirectUrl: redirectUrl,
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
      redirectUrl: 'contractId',
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
      type: 'contract',
      redirectUrl: contractId,
    );
  }

  /// Create a message notification
  static Future<void> createMessageNotification({
    required String userId,
    required String senderName,
    required String message,
    required String chatId,
  }) async {
    await createNotification(
      userId: userId,
      title: 'New Message from $senderName',
      body: message,
      type: 'system',
      redirectUrl: '/messages/$chatId',
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
      // Validate notification type
      if (!allowedTypes.contains(type)) {
        debugPrint(
            'Invalid notification type: $type. Using system type instead.');
        type = 'system';
      }

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

  /// Create a payment notification
  static Future<void> createPaymentNotification({
    required String userId,
    required String title,
    required String body,
    String? redirectUrl,
  }) async {
    await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: 'payment',
      redirectUrl: redirectUrl,
    );
  }

  /// Get all notifications for a user
  static Future<List<NotificationModel>> getNotifications(
      {required String userId}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final records = await pb.collection(_collectionName).getList(
            filter: 'user = "$userId"',
            sort: '-created',
          );

      return records.items
          .map((record) => NotificationModel.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get unread notifications count for a user
  static Future<int> getUnreadCount({required String userId}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final records = await pb.collection(_collectionName).getList(
            filter: 'user = "$userId" && read = false',
          );

      return records.items.length;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Mark all notifications as read for a user
  static Future<void> markAllAsRead({required String userId}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final records = await pb.collection(_collectionName).getList(
            filter: 'user = "$userId" && read = false',
          );

      for (var record in records.items) {
        await pb.collection(_collectionName).update(
          record.id,
          body: {'read': true},
        );
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Mark a notification as read
  static Future<void> markAsRead({required String notificationId}) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      await pb.collection(_collectionName).update(
        notificationId,
        body: {'read': true},
      );
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Subscribe to notifications for a user
  static Future<dynamic> subscribeToNotifications({
    required String userId,
    required Function(RecordSubscriptionEvent) callback,
  }) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      return pb.collection(_collectionName).subscribe(
            '*',
            callback,
            filter: 'user = "$userId"',
          );
    } catch (e) {
      debugPrint('Error subscribing to notifications: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
