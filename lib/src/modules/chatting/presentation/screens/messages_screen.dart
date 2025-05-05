import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/chatting/application/chats/chats_bloc.dart';
import 'package:connectobia/src/modules/chatting/application/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/modules/chatting/data/watermark.dart';
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
  File? watermarkedImage;
  bool enableWatermark = true; // Default to enabled

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
                  enableWatermark: enableWatermark,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      const SizedBox(width: 8),
                      BlocBuilder<RealtimeMessagingBloc,
                          RealtimeMessagingState>(
                        builder: (context, state) {
                          if (isTyping) {
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
                              child: Icon(
                                LucideIcons.send,
                                color: ShadColors.primary,
                              ),
                            );
                          } else {
                            return BlocBuilder<RealtimeMessagingBloc,
                                RealtimeMessagingState>(
                              builder: (context, state) {
                                if (state is MessagesLoaded) {
                                  return GestureDetector(
                                      child: Icon(
                                        selectedMedia
                                            ? LucideIcons.send
                                            : state.messages.items.isNotEmpty
                                                ? LucideIcons.image
                                                : LucideIcons.send,
                                        color: selectedMedia
                                            ? ShadColors.primary
                                            : null,
                                      ),
                                      onTap: () async {
                                        if (state.messages.items.isEmpty) {
                                          ShadToaster.of(context).show(
                                            ShadToast.destructive(
                                              title: const Text(
                                                'Message cannot be empty',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        int maxFileSizeInBytes = 5 * 1048576;
                                        if (selectedMedia) {
                                          sendImage(
                                            context,
                                            chatId:
                                                state.messages.items.first.chat,
                                            prevMessages: state.messages,
                                            path: watermarkedImage!.path,
                                            fileName: watermarkedImage!.path,
                                          );
                                        } else {
                                          XFile? pickedImage =
                                              await picker.pickImage(
                                            source: ImageSource.gallery,
                                          );
                                          if (pickedImage != null) {
                                            var imagePath =
                                                await pickedImage.readAsBytes();
                                            var fileSize = imagePath.length;
                                            if (fileSize <=
                                                maxFileSizeInBytes) {
                                              // Show watermark options dialog
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  title: Row(
                                                    children: [
                                                      Icon(
                                                        LucideIcons.shield,
                                                        color:
                                                            ShadColors.primary,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text(
                                                          "Protect Your Image"),
                                                    ],
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Would you like to add a watermark to protect your image from unauthorized use?",
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      SizedBox(height: 16),
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? ShadColors
                                                                  .darkForeground
                                                                  .withOpacity(
                                                                      0.1)
                                                              : ShadColors
                                                                  .lightForeground
                                                                  .withOpacity(
                                                                      0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                            color: ShadColors
                                                                .primary
                                                                .withOpacity(
                                                                    0.3),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              LucideIcons.info,
                                                              size: 18,
                                                              color: ShadColors
                                                                  .primary,
                                                            ),
                                                            SizedBox(width: 12),
                                                            Expanded(
                                                              child: Text(
                                                                "Adding a watermark places 'CONNECTOBIA' text on your image to help prevent unauthorized reuse",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: brightness ==
                                                                          Brightness
                                                                              .dark
                                                                      ? Colors
                                                                          .white70
                                                                      : Colors
                                                                          .black87,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    ShadButton.outline(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        // No watermark
                                                        setState(() {
                                                          enableWatermark =
                                                              false;
                                                        });
                                                        watermarkedImage = File(
                                                            pickedImage.path);
                                                        setState(() {
                                                          selectedMedia = true;
                                                          HapticFeedback
                                                              .lightImpact();
                                                        });
                                                      },
                                                      child: Text(
                                                          "Skip Watermark"),
                                                    ),
                                                    ShadButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        // Add watermark
                                                        setState(() {
                                                          enableWatermark =
                                                              true;
                                                        });
                                                        watermarkedImage =
                                                            await WatermarkImage
                                                                .addWaterMarkToPhoto(
                                                          image: File(
                                                              pickedImage.path),
                                                          waterMarkText:
                                                              "CONNECTOBIA",
                                                        );
                                                        setState(() {
                                                          selectedMedia = true;
                                                          HapticFeedback
                                                              .lightImpact();
                                                        });
                                                      },
                                                      child:
                                                          Text("Add Watermark"),
                                                    ),
                                                  ],
                                                ),
                                              );
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
                                          }
                                        }
                                      });
                                } else {
                                  return const SizedBox();
                                }
                              },
                            );
                          }
                        },
                      ),
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

  void sendImage(
    BuildContext context, {
    required String chatId,
    required Messages prevMessages,
    required String path,
    required String fileName,
  }) {
    HapticFeedback.lightImpact();
    String recipientId = widget.userId;
    BlocProvider.of<RealtimeMessagingBloc>(context).add(
      SendMedia(
        recipientId: recipientId,
        chatId: chatId,
        messages: prevMessages,
        path: path,
        fileName: fileName,
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
