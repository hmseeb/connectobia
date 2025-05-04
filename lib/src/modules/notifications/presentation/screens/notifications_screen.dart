import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../modules/chatting/presentation/widgets/first_message.dart';
import '../../../../shared/data/models/notification.dart';
import '../../../../theme/colors.dart';
import '../../application/notification_bloc.dart';

/// Screen that displays all notifications for a user
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final brightness = ShadTheme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: isDarkMode ? null : ShadColors.light,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded &&
                  state.notifications.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  onPressed: () {
                    context
                        .read<NotificationBloc>()
                        .add(MarkAllNotificationsAsRead());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications marked as read'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Mark all as read',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const NoMatchWidget(
                title: 'No notifications yet',
                subTitle: 'You\'ll be notified when something happens',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(FetchNotifications());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return _buildNotificationCard(
                    context: context,
                    notification: notification,
                    isDarkMode: isDarkMode,
                  );
                },
              ),
            );
          } else if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load notifications: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<NotificationBloc>()
                          .add(FetchNotifications());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const NoMatchWidget(
            title: 'No notifications yet',
            subTitle: 'You\'ll be notified when something happens',
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch notifications when the screen is opened
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required NotificationModel notification,
    required bool isDarkMode,
  }) {
    final DateFormat formatter = DateFormat('MMM d, h:mm a');
    final formattedDate = formatter.format(notification.created);

    // Determine icon based on notification type
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'message':
        icon = Icons.message;
        iconColor = Colors.blue;
        break;
      case 'campaign':
        icon = Icons.campaign;
        iconColor = Colors.green;
        break;
      case 'contract':
        icon = Icons.description;
        iconColor = Colors.orange;
        break;
      case 'contract_signed':
        icon = Icons.fact_check;
        iconColor = Colors.purple;
        break;
      case 'contract_completed':
        icon = Icons.check_circle;
        iconColor = Colors.teal;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return ShadCard(
      child: Opacity(
        opacity: notification.read ? 0.6 : 1.0,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight:
                  notification.read ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            if (!notification.read) {
              // Mark as read
              context.read<NotificationBloc>().add(
                    MarkNotificationAsRead(notification.id),
                  );
            }

            // Handle navigation based on notification type and redirectUrl
            if (notification.redirectUrl.isNotEmpty) {
              debugPrint('Navigating to: ${notification.redirectUrl}');
              // Implement navigation logic here
              // Navigator.of(context).pushNamed(notification.redirectUrl);
            }
          },
          trailing: notification.read
              ? null
              : Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: ShadColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}
