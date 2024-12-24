import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Future<dynamic> customDialogue({
  required BuildContext context,
  required Function() onContinue,
  required String title,
  required String? description,
}) {
  return showShadDialog(
    context: context,
    builder: (context) => ShadDialog.alert(
      title: Text(title),
      description: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: description != null
            ? Text(
                description,
              )
            : null,
      ),
      actions: [
        ShadButton.outline(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ShadButton(
          onPressed: onContinue,
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}
