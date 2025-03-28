import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/auth/data/repositories/auth_repo.dart';
import 'package:connectobia/src/shared/data/models/notification.dart';
import 'package:connectobia/src/shared/data/repositories/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
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
  ) {
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
      _userId ??= await AuthRepository.getUserId();

      _subscription = await NotificationRepository.subscribeToNotifications(
        userId: _userId!,
        callback: (RecordSubscriptionEvent e) {
          if (e.action == 'create') {
            final notification = NotificationModel.fromRecord(e.record!);
            add(NotificationArrived(notification));
          }
        },
      );
    } catch (e) {
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
