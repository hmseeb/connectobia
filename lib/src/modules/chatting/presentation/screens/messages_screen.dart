import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/chatting/application/chats/chats_bloc.dart';
import 'package:connectobia/src/modules/chatting/application/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/modules/chatting/domain/models/messages.dart';
import 'package:connectobia/src/modules/chatting/presentation/widgets/message_input.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../theme/colors.dart';
import '../widgets/messages_list.dart';

class MessagesScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final bool hasConnectedInstagram;
  final String collectionId;
  final String userId;
  const MessagesScreen({
    super.key,
    required this.name,
    required this.avatar,
    required this.userId,
    required this.collectionId,
    this.hasConnectedInstagram = false,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late final TextEditingController messageController;

  bool selectedMedia = false;
  final ImagePicker picker = ImagePicker();
  bool isTyping = false;
  XFile? media;

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
                      recordId: widget.userId,
                    )),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    widget.name,
                  ),
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
                  isMediaSelected: selectedMedia,
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
                                sendTextMessage(
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
                                  sendTextMessage(
                                    context,
                                    message: messageController.text,
                                    chatId: isListEmpty
                                        ? ''
                                        : state.messages.items.first.chat,
                                    prevMessages: state.messages,
                                  );
                                }
                              },
                              child: Icon(LucideIcons.send),
                            );
                          },
                        )
                      else ...[
                        BlocBuilder<RealtimeMessagingBloc,
                            RealtimeMessagingState>(
                          builder: (context, state) {
                            return GestureDetector(
                              child: Icon(
                                selectedMedia
                                    ? LucideIcons.send
                                    : LucideIcons.image,
                                color:
                                    selectedMedia ? ShadColors.primary : null,
                              ),
                              onTap: () async {
                                if (state is MessagesLoaded) {
                                  int maxFileSizeInBytes = 5 * 1048576;
                                  if (selectedMedia) {
                                    sendMediaFiles(
                                      context,
                                      chatId: state.messages.items.first.chat,
                                      prevMessages: state.messages,
                                      media: media!,
                                    );
                                  } else {
                                    media = await picker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    var imagePath = await media!.readAsBytes();
                                    var fileSize = imagePath.length;
                                    if (fileSize <= maxFileSizeInBytes) {
                                      if (media != null) {
                                        setState(() {
                                          selectedMedia = true;
                                        });
                                      }
                                      // File is too large, ask user to upload a smaller file, or compress the file/image
                                    } else {
                                      setState(() {
                                        ShadToaster.of(context).show(
                                          ShadToast.destructive(
                                            title: const Text(
                                              'File size cannot exceed 5MB',
                                            ),
                                          ),
                                        );
                                        selectedMedia = false;
                                      });
                                    }

                                    HapticFeedback.lightImpact();
                                  }
                                }
                              },
                            );
                          },
                        ),
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

  void sendMediaFiles(
    BuildContext context, {
    required String chatId,
    required Messages prevMessages,
    required XFile media,
  }) {
    HapticFeedback.lightImpact();
    String recipientId = widget.userId;
    BlocProvider.of<RealtimeMessagingBloc>(context).add(
      SendMedia(
        recipientId: recipientId,
        chatId: chatId,
        messages: prevMessages,
        image: media,
      ),
    );

    setState(() {
      selectedMedia = false;
    });
  }

  void sendTextMessage(
    BuildContext context, {
    required String message,
    required String chatId,
    required Messages prevMessages,
  }) {
    HapticFeedback.lightImpact();
    String recipientId = widget.userId;
    BlocProvider.of<RealtimeMessagingBloc>(context).add(
      SendTextMessage(
        message: message.trim(),
        recipientId: recipientId,
        chatId: chatId,
        messages: prevMessages,
        messageType: 'text',
      ),
    );
    messageController.clear();
  }
}
