import 'package:connectobia/globals/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/auth/presentation/widgets/firstlast_name.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditProfileSheet extends StatefulWidget {
  final ShadSheetSide side;
  final String firstName;
  final String lastName;
  final String username;

  const EditProfileSheet(
      {super.key,
      required this.side,
      required this.firstName,
      required this.lastName,
      required this.username});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: transparentAppBar('Edit Profile', context: context),
      body: ShadSheet(
        constraints: widget.side == ShadSheetSide.left ||
                widget.side == ShadSheetSide.right
            ? const BoxConstraints(maxWidth: 512)
            : null,
        actions: const [
          ShadButton(child: Text('Save changes')),
        ],
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              ShadAvatar(
                'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
                placeholder: Text(
                    '${widget.firstName[0]} ${widget.lastName[0]}'), //Avatar
                size: const Size(100, 100),
              ),

              //Avatar

              // Edit Picture or banner
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Edit Avatar',
                  style: TextStyle(
                    color: ShadColors.kSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FirstLastName(
                  firstName: _firstNameController,
                  lastName: _lastNameController),
              ShadInput(
                placeholder: const Text('Username'),
                controller: TextEditingController(text: widget.username),
              ),
            ]),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
