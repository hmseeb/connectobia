import 'dart:async';

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
    builder: (dialogContext) => ShadDialog.alert(
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
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
        ContinueButton(
          onContinue: onContinue,
          dialogContext: dialogContext,
        ),
      ],
    ),
  );
}

class ContinueButton extends StatefulWidget {
  final VoidCallback onContinue;
  final BuildContext dialogContext;

  const ContinueButton({
    super.key,
    required this.onContinue,
    required this.dialogContext,
  });

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> {
  bool _isButtonEnabled = true;
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      onPressed: _isButtonEnabled ? _handleContinue : null,
      child: const Text('Continue'),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleContinue() {
    if (!_isButtonEnabled) return;

    setState(() {
      _isButtonEnabled = false;
    });

    // Execute the callback
    widget.onContinue();

    // Close the dialog
    Navigator.of(widget.dialogContext).pop(true);

    // Re-enable the button after a delay (not usually needed since dialog closes)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isButtonEnabled = true;
        });
      }
    });
  }
}
