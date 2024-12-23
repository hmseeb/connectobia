import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/chatting/application/chats/chats_bloc.dart';
import 'package:connectobia/src/modules/chatting/domain/models/messages.dart';
import 'package:connectobia/src/modules/chatting/presentation/widgets/message_input.dart';
import 'package:connectobia/src/shared/application/realtime/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../theme/colors.dart';
import '../widgets/messages_list.dart';

class SingleChatScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final bool hasConnectedInstagram;
  final String collectionId;
  final String userId;
  const SingleChatScreen({
    super.key,
    required this.name,
    required this.avatar,
    required this.userId,
    required this.collectionId,
    required this.hasConnectedInstagram,
  });

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  late final TextEditingController messageController;
  bool isTyping = false;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = ShadTheme.of(context).brightness;
    return BlocBuilder<ChatsBloc, ChatsState>(
      builder: (context, state) {
        return BlocListener<RealtimeMessagingBloc, RealtimeMessagingState>(
          listener: (context, state) {
            if (state is MessageNotSent) {
              ShadToaster.of(context).show(
                ShadToast.destructive(
                  title: Text(state.message),
                ),
              );
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor:
                  brightness == Brightness.dark ? null : ShadColors.light,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    backgroundImage:
                        CachedNetworkImageProvider(Avatar.getUserImage(
                      collectionId: widget.collectionId,
                      image: widget.avatar,
                      userId: widget.userId,
                    )),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    widget.name,
                  ),
                  // Blue tick
                  if (widget.hasConnectedInstagram)
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                    ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            body: Column(
              children: [
                MessagesList(
                  recipientName: widget.name,
                  senderId: widget.userId,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      BlocBuilder<RealtimeMessagingBloc,
                          RealtimeMessagingState>(
                        builder: (context, state) {
                          return MessageInput(
                            messageController: messageController,
                            onSubmitted: (value) {
                              if (state is MessagesLoaded && value.isNotEmpty) {
                                bool isListEmpty = state.messages.items.isEmpty;
                                sendMessage(
                                  context,
                                  message: messageController.text,
                                  chatId: isListEmpty
                                      ? ''
                                      : state.messages.items.first.chat,
                                  prevMessages: state.messages,
                                );
                              }
                            },
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  isTyping = true;
                                });
                              } else {
                                setState(() {
                                  isTyping = false;
                                });
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      if (isTyping)
                        BlocBuilder<RealtimeMessagingBloc,
                            RealtimeMessagingState>(
                          builder: (context, state) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  isTyping = false;
                                });
                                if (state is MessagesLoaded &&
                                    messageController.text.isNotEmpty) {
                                  bool isListEmpty =
                                      state.messages.items.isEmpty;
                                  sendMessage(
                                    context,
                                    message: messageController.text,
                                    chatId: isListEmpty
                                        ? ''
                                        : state.messages.items.first.chat,
                                    prevMessages: state.messages,
                                  );
                                }
                              },
                              child: Icon(
                                LucideIcons.send,
                                color: ShadColors.primary,
                              ),
                            );
                          },
                        )
                      else ...[
                        Icon(Icons.mic),
                        const SizedBox(width: 16),
                        Icon(LucideIcons.image),
                      ],
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  void sendMessage(
    BuildContext context, {
    required String message,
    required String chatId,
    required Messages prevMessages,
  }) {
    HapticFeedback.lightImpact();
    String recipientId = widget.userId;
    BlocProvider.of<RealtimeMessagingBloc>(context).add(
      SendMessage(
        message: message.trim(),
        recipientId: recipientId,
        chatId: chatId,
        messages: prevMessages,
      ),
    );
    messageController.clear();
  }
}
