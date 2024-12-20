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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['senderId'] == currentUserID;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isMe
                          ? ShadColors.primary
                          : brightness == Brightness.light
                              ? ShadColors.lightForeground
                              : ShadColors.darkForeground,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isMe
                            ? Colors.white
                            : brightness == Brightness.dark
                                ? ShadColors.light
                                : ShadColors.dark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ShadInputFormField(
                    placeholder: Text('Type here'),
                    onChanged: (value) {
                      // Placeholder function for typing message
                    },
                    decoration: ShadDecoration(
                      // no border
                      border: ShadBorder.all(
                        color: Colors.transparent,
                      ),
                      color: brightness == Brightness.dark
                          ? ShadColors.darkForeground
                          : ShadColors.lightForeground,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.send),
                  onPressed: () {
                    // Placeholder function for send message button
                  },
                ),
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
    super.dispose();
  }
}
