import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/chatting/presentation/widgets/first_message.dart';
import 'package:connectobia/src/modules/chatting/presentation/widgets/message_input.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../theme/colors.dart';
import '../widgets/messages_list.dart';

class SingleChatScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final bool hasConnectedInstagram;
  final String collectionId;
  final String userId;
  const SingleChatScreen(
      {super.key,
      required this.name,
      required this.avatar,
      required this.userId,
      required this.collectionId,
      required this.hasConnectedInstagram});

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController messageController;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    messageController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = ShadTheme.of(context).brightness;
    // Dummy messages data
    final List<Map<String, dynamic>> messages = [
      {'text': 'Looking forward to our meeting.', 'senderId': '2'},
      {'text': 'I am great, thanks for asking!', 'senderId': '1'},
      {'text': 'Hi! I am good. How about you?', 'senderId': '2'},
      {'text': 'Hey! How are you?', 'senderId': '1'},
    ];

    messages.clear();

    // Dummy current user ID
    final String currentUserID = '1';
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor:
            brightness == Brightness.dark ? ShadColors.dark : ShadColors.light,
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
              backgroundImage: CachedNetworkImageProvider(Avatar.getUserImage(
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
          if (messages.isNotEmpty)
            MessagesList(
              scrollController: _scrollController,
              messages: messages,
              currentUserID: currentUserID,
            )
          else ...[
            Spacer(),
            FirstMessage(name: widget.name),
            Spacer(),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                MessageInput(
                  messageController: messageController,
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
                ),
                const SizedBox(width: 16),
                if (isTyping)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isTyping = false;
                      });
                      messageController.clear();
                    },
                    child: Icon(
                      LucideIcons.send,
                      color: ShadColors.primary,
                    ),
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
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
