import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:connectobia/src/modules/chatting/application/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/modules/chatting/domain/models/message.dart';
import 'package:connectobia/src/modules/chatting/presentation/widgets/first_message.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:connectobia/src/shared/data/constants/date_and_time.dart';
import 'package:connectobia/src/shared/data/constants/messages.dart';
import 'package:connectobia/src/shared/presentation/widgets/fullscreen_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../../theme/colors.dart';

class ChatMedia extends StatelessWidget {
  final Message message;
  final bool isMe;
  const ChatMedia({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive image size
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.7; // 70% of screen width
    final maxHeight = maxWidth; // Square or maintain aspect ratio

    final imageUrl = Avatar.getUserImage(
        collectionId: message.collectionId!,
        recordId: message.id!,
        image: message.image!.first);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {
            // Open fullscreen image viewer with our shared component
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FullscreenImage(
                  imageUrl: imageUrl,
                  heroTag: 'chat_image_${message.id}',
                ),
              ),
            );
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: maxWidth,
                    height: maxWidth * 0.75,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: maxWidth,
                    height: maxWidth * 0.75,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MessagesList extends StatelessWidget {
  final String recipientName;
  final String senderId;
  final Message? message;
  final bool isMediaSelected;
  final bool enableWatermark;
  final Function()? onDismiss;

  final String newMessage = '';

  const MessagesList({
    super.key,
    required this.recipientName,
    required this.senderId,
    this.message,
    required this.isMediaSelected,
    this.enableWatermark = true,
    this.onDismiss,
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
                final myMessageIndex = state.messages.items
                    .indexWhere((msg) => msg.senderId == state.selfId);
                final otherMessageIndex = state.messages.items
                    .indexWhere((msg) => msg.senderId != state.selfId);
                return Column(
                  children: [
                    SwipeTo(
                      leftSwipeWidget: Text(DateAndTime.formatDateTimeTo12Hour(
                          DateTime.parse(state.messages.items[index].created))),
                      onLeftSwipe: (details) {},
                      onRightSwipe: (details) {},
                      rightSwipeWidget: Text(DateAndTime.formatDateTimeTo12Hour(
                          DateTime.parse(state.messages.items[index].created))),
                      child: state.messages.items[index].messageType == 'text'
                          ? BubbleSpecialThree(
                              sent: state.messages.items[index].sent == null &&
                                  isMe,
                              isSender: isMe,
                              tail: index == myMessageIndex ||
                                  index == otherMessageIndex,
                              text: state.messages.items[index].messageText,
                              color: isMe
                                  ? ShadColors.primary
                                  : brightness == Brightness.light
                                      ? ShadColors.lightForeground
                                      : ShadColors.darkForeground,
                              textStyle: TextStyle(
                                  color: isMe
                                      ? ShadColors.light
                                      : brightness == Brightness.dark
                                          ? ShadColors.light
                                          : ShadColors.dark),
                            )
                          : ChatMedia(
                              message: state.messages.items[index],
                              isMe: isMe,
                            ),
                    ),
                    if (index == 0 && isMediaSelected) ...[
                      ShadAlert(
                        iconSrc: LucideIcons.image,
                        title: Text(
                          'Selected an image${enableWatermark ? " (Watermarked)" : " (No Watermark)"}',
                        ),
                        decoration: ShadDecoration(color: ShadColors.success),
                      ),
                    ]
                  ],
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
