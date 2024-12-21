import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({
    super.key,
    required ScrollController scrollController,
    required this.messages,
    required this.currentUserID,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final List<Map<String, dynamic>> messages;
  final String currentUserID;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = ShadTheme.of(context).brightness;
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        controller: _scrollController,
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isMe = message['senderId'] == currentUserID;
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
    );
  }
}
