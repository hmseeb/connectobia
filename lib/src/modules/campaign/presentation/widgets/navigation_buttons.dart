import 'dart:async';

import 'package:connectobia/src/shared/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NavigationButtons extends StatefulWidget {
  final int currentStep;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String? submitLabel;

  const NavigationButtons({
    super.key,
    required this.currentStep,
    required this.onPrevious,
    required this.onNext,
    this.submitLabel,
  });

  @override
  State<NavigationButtons> createState() => _NavigationButtonsState();
}

class _NavigationButtonsState extends State<NavigationButtons> {
  bool _isNextButtonEnabled = true;
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    final isFirstStep = widget.currentStep == 1;
    final isLastStep = widget.currentStep == 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        isFirstStep
            ? ShadButton.outline(
                onPressed: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              )
            : ShadButton.outline(
                onPressed: widget.onPrevious,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

        // Next/Submit button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ShadButton(
            onPressed: _isNextButtonEnabled ? _handleNextPress : null,
            backgroundColor: _isNextButtonEnabled
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.6),
            foregroundColor: AppColors.textLight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLastStep
                        ? (widget.submitLabel ?? 'Submit Campaign')
                        : 'Next',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastStep ? Icons.check_circle : Icons.arrow_forward,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleNextPress() {
    if (!_isNextButtonEnabled) return;

    setState(() {
      _isNextButtonEnabled = false;
    });

    // Call the onNext callback immediately
    widget.onNext();

    // Set a debounce timer to prevent rapid clicks
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isNextButtonEnabled = true;
        });
      }
    });
  }
}
