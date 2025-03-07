import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../theme/colors.dart';

class ProfileBioField extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditable;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isRequired;
  final Function(String)? onChanged;

  const ProfileBioField({
    super.key,
    required this.label,
    required this.value,
    this.isEditable = false,
    this.controller,
    this.validator,
    this.isRequired = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return isEditable
        ? _buildEditableBioField(context)
        : _buildReadOnlyBioField(context);
  }

  Widget _buildEditableBioField(BuildContext context) {
    if (controller == null) {
      throw ArgumentError(
          'Controller must be provided for editable ProfileBioField');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRequired ? '$label *' : label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ShadColors.disabled
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          ShadInputFormField(
            controller: controller,
            validator: validator,
            minLines: 3,
            maxLines: 5,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyBioField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? ShadColors.disabled
                  : Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'No bio added yet' : value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: value.isEmpty
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? ShadColors.disabled
                      : Colors.grey)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isEditable;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isRequired;
  final Function(String)? onChanged;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isEditable = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return isEditable
        ? _buildEditableField(context)
        : _buildReadOnlyField(context);
  }

  Widget _buildEditableField(BuildContext context) {
    if (controller == null) {
      throw ArgumentError(
          'Controller must be provided for editable ProfileField');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRequired ? '$label *' : label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ShadColors.disabled
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          ShadInputFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            prefix: Icon(
              icon,
              size: 18,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ShadColors.disabled
                  : Colors.grey,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? ShadColors.disabled
                  : Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ShadColors.disabled
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
