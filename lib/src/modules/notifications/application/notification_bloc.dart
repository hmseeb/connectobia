import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/auth/data/repositories/auth_repo.dart';
import 'package:connectobia/src/shared/data/models/notification.dart';
import 'package:connectobia/src/shared/data/repositories/notification_repository.dart';
import 'package:connectobia/src/shared/data/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// Bloc for managing notification state and operations
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  dynamic _subscription;
  String? _userId;

  NotificationBloc() : super(NotificationInitial()) {
    // Fetch notifications
    on<FetchNotifications>(_onFetchNotifications);

    // Subscribe to notifications
    on<SubscribeToNotifications>(_onSubscribeToNotifications);

    // Unsubscribe from notifications
    on<UnsubscribeFromNotifications>(_onUnsubscribeFromNotifications);

    // Mark notification as read
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);

    // Mark all notifications as read
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);

    // Handle new notification
    on<NotificationArrived>(_onNotificationArrived);

    // Initialize notification service
    on<InitializeNotificationService>(_onInitializeNotificationService);
  }

  @override
  Future<void> close() {
    if (_subscription != null) {
      _subscription.unsubscribe();
    }
    return super.close();
  }

  /// Handles fetching notifications
  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationsLoading());
    try {
      _userId ??= await AuthRepository.getUserId();

      final notifications = await NotificationRepository.getNotifications(
        userId: _userId!,
      );

      final unreadCount = await NotificationRepository.getUnreadCount(
        userId: _userId!,
      );

      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Handles initializing the notification service
  Future<void> _onInitializeNotificationService(
    InitializeNotificationService event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Initialize the notification service
      await NotificationService.initialize();

      // Set up the notification action listeners
      await NotificationService.setListeners(
        onNotificationCreated: (receivedNotification) {
          debugPrint('Notification created: ${receivedNotification.title}');
        },
        onNotificationDisplayed: (receivedNotification) {
          debugPrint('Notification displayed: ${receivedNotification.title}');
        },
        onActionReceived: (receivedAction) async {
          debugPrint(
              'Notification action received: ${receivedAction.buttonKeyPressed}');
          // Handle notification action
          await NotificationService.handleNotificationAction(
            receivedAction,
            markAsRead: (notificationId) async {
              add(MarkNotificationAsRead(notificationId));
            },
          );
          // Handle navigation if needed based on payload
          if (receivedAction.payload != null &&
              receivedAction.payload!.containsKey('redirectUrl') &&
              receivedAction.payload!['redirectUrl']!.isNotEmpty) {
            debugPrint(
                'Should navigate to: ${receivedAction.payload!['redirectUrl']}');
            // Navigation logic would go here
          }
        },
        onDismissActionReceived: (receivedAction) {
          debugPrint('Notification dismissed: ${receivedAction.title}');
        },
      );

      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
      emit(NotificationError(e.toString()));
    }
  }

  /// Handles marking all notifications as read
  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _userId ??= await AuthRepository.getUserId();

      await NotificationRepository.markAllAsRead(
        userId: _userId!,
      );

      add(FetchNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Handles marking a notification as read
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await NotificationRepository.markAsRead(
        notificationId: event.notificationId,
      );

      add(FetchNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Handles when a new notification arrives
  void _onNotificationArrived(
    NotificationArrived event,
    Emitter<NotificationState> emit,
  ) async {
    // Show in-app notification using the notification service
    try {
      await NotificationService.showNotification(event.notification);
    } catch (e) {
      debugPrint('Error showing in-app notification: $e');
    }

    emit(NotificationReceived(notification: event.notification));

    // Refresh the notifications list
    add(FetchNotifications());
  }

  /// Handles subscribing to notifications
  Future<void> _onSubscribeToNotifications(
    SubscribeToNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Check if user is already authenticated before proceeding
      try {
        _userId = await AuthRepository.getUserId();

        if (_userId == null || _userId!.isEmpty) {
          debugPrint(
              'Cannot subscribe to notifications: User not authenticated');
          return; // Exit early but don't emit an error
        }

        debugPrint('Subscribing to notifications for user: $_userId');

        _subscription = await NotificationRepository.subscribeToNotifications(
          userId: _userId!,
          callback: (RecordSubscriptionEvent e) {
            if (e.action == 'create') {
              final notification = NotificationModel.fromRecord(e.record!);
              add(NotificationArrived(notification));
            }
          },
        );

        debugPrint('Successfully subscribed to notifications');
      } catch (e) {
        // If it's an auth error, just log it but don't emit error state
        debugPrint('Auth error when subscribing to notifications: $e');
      }
    } catch (e) {
      debugPrint('Error in notification subscription: $e');
      emit(NotificationError(e.toString()));
    }
  }

  /// Handles unsubscribing from notifications
  Future<void> _onUnsubscribeFromNotifications(
    UnsubscribeFromNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      if (_subscription != null) {
        _subscription.unsubscribe();
        _subscription = null;
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
