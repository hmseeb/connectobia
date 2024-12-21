import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../theme/colors.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({
    super.key,
    required TextEditingController messageController,
  }) : _messageController = messageController;

  final TextEditingController _messageController;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = ShadTheme.of(context).brightness;
    return Expanded(
      child: ShadInputFormField(
        controller: _messageController,
        placeholder: Text('Enter your message'),
        decoration: ShadDecoration(
          secondaryFocusedBorder: ShadBorder.all(
            width: 2,
            color: brightness == Brightness.light
                ? ShadColors.dark
                : ShadColors.light,
            radius: BorderRadius.circular(24),
          ),
          border: ShadBorder.all(
            color: Colors.transparent,
            radius: BorderRadius.circular(24),
          ),
          color: brightness == Brightness.dark
              ? ShadColors.darkForeground
              : ShadColors.lightForeground,
        ),
      ),
    );
  }
}
