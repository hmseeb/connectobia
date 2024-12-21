import 'package:connectobia/modules/messaging/presentation/widgets/message_input.dart';
import 'package:connectobia/modules/messaging/presentation/widgets/messages_list.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SingleChatScreen extends StatefulWidget {
  const SingleChatScreen({super.key});

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _messageController;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _messageController = TextEditingController();
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
            const CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Text('U'),
            ),
            const SizedBox(width: 24),
            const Text('Haseeb Azhar'),
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
            scrollController: _scrollController,
            messages: messages,
            currentUserID: currentUserID,
            brightness: brightness,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                MessageInput(
                  messageController: _messageController,
                ),
                const SizedBox(width: 16),
                if (isTyping)
                  GestureDetector(
                    onTap: () {
                      isTyping = false;
                      _messageController.clear();
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
    _messageController.dispose();
    super.dispose();
  }
}
