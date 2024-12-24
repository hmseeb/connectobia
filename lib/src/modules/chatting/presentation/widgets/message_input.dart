import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../theme/colors.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  const MessageInput({
    super.key,
    required this.onChanged,
    required this.onSubmitted,
    required this.messageController,
  });

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = ShadTheme.of(context).brightness;
    return Expanded(
      child: ShadInputFormField(
        maxLines: 5,
        minLines: 1,
        controller: messageController,
        maxLength: 4000,
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
        onChanged: onChanged,
        onSubmitted: (value) => onSubmitted!(value),
        validator: (value) {
          if (value.length > 4000) {
            return 'Please enter a message';
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}
