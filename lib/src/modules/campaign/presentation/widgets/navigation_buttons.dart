import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final int currentStep;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const NavigationButtons({
    super.key,
    required this.currentStep,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Keep space for Back button even when it's hidden
        if (currentStep > 1)
          TextButton(
            onPressed: onPrevious,
            child: const Text('Back'),
          )
        else
          const SizedBox(width: 70), // Maintain space for hidden Back button
        TextButton(
          onPressed: onNext,
          child: const Text('Next'),
        ),
      ],
    );
  }
}