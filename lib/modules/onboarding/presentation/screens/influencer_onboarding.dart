import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:flutter/material.dart';

class InfluencerOnboarding extends StatefulWidget {
  final User user;

  const InfluencerOnboarding({super.key, required this.user});

  @override
  State<InfluencerOnboarding> createState() => _InfluencerOnboardingState();
}

class _InfluencerOnboardingState extends State<InfluencerOnboarding> {
  final int _currentStep = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stepper(
        steps: [
          Step(
            title: const Text('Step 1'),
            content: const Text('Step 1 content'),
            state: _currentStep == 0 ? StepState.editing : StepState.complete,
          ),
          Step(
            title: const Text('Step 2'),
            content: const Text('Step 2 content'),
            state: _currentStep == 1 ? StepState.editing : StepState.complete,
          ),
          Step(
            title: const Text('Step 3'),
            content: const Text('Step 3 content'),
            state: _currentStep == 2 ? StepState.editing : StepState.complete,
          ),
        ],
      ),
    );
  }
}
