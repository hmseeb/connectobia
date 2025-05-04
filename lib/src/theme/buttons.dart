import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A primary button for authentication screens
///
/// This button is used in the authentication screens
/// to provide a consistent look and feel for the buttons.
///
/// {@category Theme}
class PrimaryButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final void Function() onPressed;
  final Duration debounceTime;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.debounceTime = const Duration(milliseconds: 800),
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isButtonEnabled = true;
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    // get shad theme data
    final shadTheme = ShadTheme.of(context);
    return SizedBox(
      width: 350,
      child: ShadButton(
        onPressed:
            (widget.isLoading || !_isButtonEnabled) ? null : _handlePress,
        child: widget.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: shadTheme.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                ),
              )
            : Text(widget.text),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handlePress() {
    // If already loading or debounce is active, ignore the click
    if (widget.isLoading || !_isButtonEnabled) return;

    setState(() {
      _isButtonEnabled = false;
    });

    // Call the original onPressed callback
    widget.onPressed();

    // Start the debounce timer
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceTime, () {
      if (mounted) {
        setState(() {
          _isButtonEnabled = true;
        });
      }
    });
  }
}
