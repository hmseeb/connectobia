import 'package:connectobia/common/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:connectobia/modules/onboarding/application/bloc/influencer_onboard_bloc.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_picker_text_field/open_street_location_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:social_auth_btn_kit/social_auth_btn_kit.dart';

class InfluencerOnboarding extends StatefulWidget {
  final User user;

  const InfluencerOnboarding({super.key, required this.user});

  @override
  State<InfluencerOnboarding> createState() => _InfluencerOnboardingState();
}

class _InfluencerOnboardingState extends State<InfluencerOnboarding> {
  final TextEditingController locationName = TextEditingController();
  int _currentStep = 0;
  String token = '', userid = '', username = '';
  String instagramButtonText = 'Connect Instagram';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfluencerOnboardBloc, InfluencerOnboardState>(
      listener: (context, state) {
        if (state is ConnectedInstagram) {
          setState(() {
            instagramButtonText = 'Connected Account';
          });
        } else if (state is ConnectingInstagram) {
          setState(() {
            instagramButtonText = 'Connecting...';
          });
        } else if (state is ConnectingInstagramFailure) {
          setState(() {
            instagramButtonText = 'Connect Instagram';
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: transparentAppBar('Onboarding', context: context),
          body: Stepper(
            currentStep: _currentStep,
            onStepTapped: (step) {
              setState(() {
                _currentStep = step;
              });
            },
            onStepCancel: () {
              setState(() {
                if (_currentStep > 0) {
                  _currentStep -= 1;
                } else {
                  _currentStep = 0;
                }
              });
            },
            onStepContinue: () {
              setState(() {
                if (_currentStep < 2) {
                  _currentStep += 1;
                } else {
                  _currentStep = 0;
                }
              });
            },
            steps: [
              Step(
                title: const Text('Personal Details'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date of birth'),
                    const ShadDatePicker(),
                    const SizedBox(height: 8),
                    Text('Gender'),
                    ShadRadioGroup<String>(
                      items: [
                        ShadRadio(
                          label: Text('Male'),
                          value: 'male',
                        ),
                        ShadRadio(
                          label: Text('Female'),
                          value: 'female',
                        ),
                        ShadRadio(
                          label: Text('Other'),
                          value: 'other',
                        ),
                      ],
                      axis: Axis.horizontal,
                    )
                  ],
                ),
                state:
                    _currentStep == 0 ? StepState.editing : StepState.complete,
                subtitle: _currentStep == 0 ? null : Text('Completed'),
              ),
              Step(
                title: const Text('Pick your location'),
                content: Column(
                  children: <Widget>[
                    const SizedBox(height: 8),
                    LocationPicker(
                      label: 'Location',
                      controller: locationName,
                      onSelect: (data) {
                        locationName.text = data.displayname;
                      },
                    ),
                  ],
                ),
                state:
                    _currentStep == 1 ? StepState.editing : StepState.complete,
                isActive: _currentStep == 1,
                subtitle: _currentStep == 1 ? null : Text('Completed'),
              ),
              Step(
                title: const Text('Connect Social'),
                content: Column(
                  children: [
                    SocialAuthBtn(
                      icon: 'assets/icons/instagram.png',
                      onPressed: () {
                        BlocProvider.of<InfluencerOnboardBloc>(context)
                            .add(ConnectInstagram());
                      },
                      text: instagramButtonText,
                      borderSide: const BorderSide(),
                      backgroundColor: ShadColors.lightForeground,
                    ),
                  ],
                ),
                state:
                    _currentStep == 2 ? StepState.editing : StepState.complete,
                isActive: _currentStep == 2,
                subtitle: _currentStep == 2 ? null : Text('Completed'),
              ),
            ],
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: <Widget>[
                    details.stepIndex == 0
                        ? const SizedBox(width: 10)
                        : ShadButton.outline(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                    const SizedBox(width: 10),
                    details.stepIndex == 2
                        ? ShadButton(
                            onPressed: details.onStepContinue,
                            child: const Text('Submit'),
                          )
                        : ShadButton(
                            onPressed: details.onStepContinue,
                            child: const Text('Next'),
                          ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
