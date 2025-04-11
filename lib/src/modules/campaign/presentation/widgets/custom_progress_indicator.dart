import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final int currentStep;

  const CustomProgressIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Row(
          children: [
            // Step Circle
            Container(
              width: 30,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentStep > index ? Colors.deepOrange : Colors.grey[300],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: currentStep > index ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Line between steps (except for the last step)
            if (index < 3)
              Container(
                width: 50,
                height: 2,
                color: currentStep > index + 1 ? Colors.deepOrange : Colors.grey[300],
              ),
          ],
        );
      }),
    );
  }
}