import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/modules/chatting/presentation/widgets/first_message.dart';
import 'package:connectobia/src/shared/application/realtime/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/shared/data/constants/date_and_time.dart';
import 'package:connectobia/src/shared/data/constants/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../theme/colors.dart';

class MessagesList extends StatelessWidget {
  final String recipientName;
  final String senderId;
  final Message? message;

  final String newMessage = '';

  const MessagesList({
    super.key,
    required this.recipientName,
    required this.senderId,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = ShadTheme.of(context).brightness;

    return BlocConsumer<RealtimeMessagingBloc, RealtimeMessagingState>(
      listener: (context, state) {
        if (state is RealtimeMessagingError) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: Text(state.error),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MessagesLoaded && state.messages.items.isNotEmpty) {
          return Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              reverse: true,
              itemCount: state.messages.items.length,
              itemBuilder: (context, index) {
                final isMe =
                    state.messages.items[index].senderId == state.selfId;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isMe
                          ? ShadColors.primary
                          : brightness == Brightness.light
                              ? ShadColors.lightForeground
                              : ShadColors.darkForeground,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          state.messages.items[index].messageText,
                          style: TextStyle(
                            color: isMe
                                ? ShadColors.light
                                : brightness == Brightness.dark
                                    ? ShadColors.light
                                    : ShadColors.dark,
                          ),
                        ),
                        if (state.messages.items[index].sent == null)
                          Wrap(
                            spacing: 4,
                            children: [
                              Text(
                                DateAndTime.formatDateTimeTo12Hour(
                                    DateTime.parse(
                                        state.messages.items[index].created)),
                                style: TextStyle(
                                  color: isMe
                                      ? ShadColors.light
                                      : brightness == Brightness.dark
                                          ? ShadColors.light
                                          : ShadColors.dark,
                                  fontSize: 11,
                                ),
                              ),
                              if (isMe)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      if (state.messages.items[index].expand!
                                          .chat.isRead)
                                        Positioned(
                                          bottom: -3,
                                          left: 0,
                                          child: Icon(Icons.check,
                                              size: 12,
                                              color: ShadColors.light),
                                        ),
                                      Icon(
                                        Icons.check,
                                        size: 12,
                                        color: isMe
                                            ? ShadColors.light
                                            : brightness == Brightness.dark
                                                ? ShadColors.light
                                                : ShadColors.dark,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          )
                        else if (state.messages.items[index].sent != null &&
                            !state.messages.items[index].sent!)
                          Wrap(
                            children: [
                              Text(
                                DateAndTime.formatDateTimeTo12Hour(
                                    DateTime.parse(
                                        state.messages.items[index].created)),
                                style: TextStyle(
                                  color: isMe
                                      ? ShadColors.light
                                      : brightness == Brightness.dark
                                          ? ShadColors.light
                                          : ShadColors.dark,
                                  fontSize: 11,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: isMe
                                      ? ShadColors.light
                                      : brightness == Brightness.dark
                                          ? ShadColors.light
                                          : ShadColors.dark,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is MessagesLoading) {
          return MessagesSkeleton();
        } else if (state is MessagesLoadingError) {
          return Expanded(
            child: Column(
              children: [
                Spacer(),
                Text('data could not be loaded'),
                Spacer(),
              ],
            ),
          );
        } else {
          return Expanded(
            child: Column(
              children: [
                Spacer(),
                NoMatchWidget(
                  title: 'No messages yet',
                  subTitle: 'This is the very beginning of your conversation',
                ),
                Spacer(),
              ],
            ),
          );
        }
      },
    );
  }
}

class MessagesSkeleton extends StatefulWidget {
  const MessagesSkeleton({
    super.key,
  });

  @override
  State<MessagesSkeleton> createState() => _MessagesSkeletonState();
}

class _MessagesSkeletonState extends State<MessagesSkeleton> {
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final Brightness brightness = ShadTheme.of(context).brightness;

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        controller: scrollController,
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isMe = message['senderId'] == "2";
          return Skeletonizer(
            enabled: true,
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: brightness == Brightness.light
                      ? ShadColors.lightForeground
                      : ShadColors.darkForeground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  message['text'],
                  style: TextStyle(
                    color: brightness == Brightness.dark
                        ? ShadColors.light
                        : ShadColors.dark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
