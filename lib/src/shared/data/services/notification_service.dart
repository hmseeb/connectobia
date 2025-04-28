import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/notification.dart' as app_models;

/// Service for handling in-app notifications using awesome notifications
class NotificationService {
  /// Handle notification based on received action
  static Future<void> handleNotificationAction(ReceivedAction receivedAction,
      {required Function(String) markAsRead}) async {
    // Get payload data
    final notificationId = receivedAction.payload?['notificationId'];

    // Check if the action is to mark as read
    if (receivedAction.buttonKeyPressed == 'MARK_AS_READ' &&
        notificationId != null) {
      await markAsRead(notificationId);
    }
  }

  /// Initialize the notification service
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      // Set the default notification icon
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: ShadColors.primary,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'campaign_channel',
          channelName: 'Campaign notifications',
          channelDescription:
              'Notification channel for campaign related notifications',
          defaultColor: Colors.green,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'contract_channel',
          channelName: 'Contract notifications',
          channelDescription:
              'Notification channel for contract related notifications',
          defaultColor: Colors.orange,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'content_channel',
          channelName: 'Content notifications',
          channelDescription:
              'Notification channel for content related notifications',
          defaultColor: Colors.purple,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'payment_channel',
          channelName: 'Payment notifications',
          channelDescription:
              'Notification channel for payment related notifications',
          defaultColor: Colors.teal,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'messages_channel',
          channelName: 'Message notifications',
          channelDescription: 'Notification channel for message notifications',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          vibrationPattern: highVibrationPattern,
        ),
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic notifications',
        )
      ],
      debug: true,
    );

    // Request notification permission
    await requestNotificationPermission();
  }

  /// Request permission to send notifications
  static Future<bool> requestNotificationPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      return await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  /// Set up notification action listeners
  static Future<void> setListeners({
    required Function(ReceivedNotification) onNotificationCreated,
    required Function(ReceivedNotification) onNotificationDisplayed,
    required Function(ReceivedAction) onActionReceived,
    required Function(ReceivedAction) onDismissActionReceived,
  }) async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        onActionReceived(receivedAction);
      },
      onNotificationCreatedMethod:
          (ReceivedNotification receivedNotification) async {
        onNotificationCreated(receivedNotification);
      },
      onNotificationDisplayedMethod:
          (ReceivedNotification receivedNotification) async {
        onNotificationDisplayed(receivedNotification);
      },
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) async {
        onDismissActionReceived(receivedAction);
      },
    );
  }

  /// Show a notification from a NotificationModel
  static Future<void> showNotification(
      app_models.NotificationModel notification) async {
    // Determine which channel to use based on notification type
    String channelKey;

    switch (notification.type) {
      case 'campaign':
        channelKey = 'campaign_channel';
        break;
      case 'contract':
        channelKey = 'contract_channel';
        break;
      case 'content':
        channelKey = 'content_channel';
        break;
      case 'payment':
        channelKey = 'payment_channel';
        break;
      case 'system':
        if (notification.title.toLowerCase().contains('message')) {
          channelKey = 'messages_channel';
        } else {
          channelKey = 'basic_channel';
        }
        break;
      default:
        channelKey = 'basic_channel';
    }

    // Create a notification ID based on current time
    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    // Trigger notification with vibration feedback
    HapticFeedback.vibrate();

    // Create the notification
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: notification.title,
        body: notification.body,
        payload: {
          'redirectUrl': notification.redirectUrl,
          'notificationId': notification.id,
          'type': notification.type,
        },
        autoDismissible: true,
        category: _getNotificationCategory(notification.type),
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'MARK_AS_READ',
          label: 'Mark as read',
        ),
      ],
    );
  }

  /// Get the appropriate notification category based on the notification type
  static NotificationCategory _getNotificationCategory(String type) {
    switch (type) {
      case 'campaign':
        return NotificationCategory.Event;
      case 'contract':
        return NotificationCategory.Event;
      case 'content':
        return NotificationCategory.Recommendation;
      case 'payment':
        return NotificationCategory.Service;
      case 'system':
        return NotificationCategory.Message;
      default:
        return NotificationCategory.Reminder;
    }
  }
}
