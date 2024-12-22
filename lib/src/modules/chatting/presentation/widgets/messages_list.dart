import 'package:connectobia/src/modules/chatting/application/messages/messages_bloc.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/modules/chatting/presentation/widgets/first_message.dart';
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

  const MessagesList({
    super.key,
    required this.recipientName,
    required this.senderId,
    this.message,
  });

  final String newMessage = '';

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = ShadTheme.of(context).brightness;

    return BlocBuilder<MessagesBloc, MessagesState>(
      builder: (context, state) {
        if (state is MessagesLoaded) {
          if (state.messages.totalItems == 0) {
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
          return Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              reverse: true,
              itemCount: state.messages.items.length,
              itemBuilder: (context, index) {
                final Message message =
                    state.messages.items.reversed.toList()[index];
                final isMe = message.senderId == state.selfId;
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
                    child: RichText(
                      text: TextSpan(
                        text: message.messageText,
                        style: TextStyle(
                          color: isMe
                              ? ShadColors.light
                              : brightness == Brightness.dark
                                  ? ShadColors.light
                                  : ShadColors.dark,
                        ),
                        children: [
                          TextSpan(
                            text:
                                ' ${DateAndTime.formatDateTimeTo12Hour(message.created)}',
                            style: TextStyle(
                              color: isMe
                                  ? ShadColors.light
                                  : brightness == Brightness.dark
                                      ? ShadColors.light
                                      : ShadColors.dark,
                              fontSize: 10,
                            ),
                          ),
                          if (message.sent != null && !message.sent!)
                            WidgetSpan(
                              child: Padding(
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
                            ),
                          if (isMe && message.sent == null) ...[
                            WidgetSpan(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      bottom: 0,
                                      left: 4,
                                      child: Icon(
                                        Icons.check,
                                        size: 12,
                                        color: isMe
                                            ? ShadColors.light
                                            : brightness == Brightness.dark
                                                ? ShadColors.light
                                                : ShadColors.dark,
                                      ),
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
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is MessagesLoading) {
          return MessagesSkeleton();
        } else {
          return const SizedBox();
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
