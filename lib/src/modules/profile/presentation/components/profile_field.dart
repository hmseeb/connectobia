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

  Widget _buildInfoCard(
    BuildContext context, {
    required String text,
    Widget? leading,
    bool isMultiline = false,
  }) {
    return ShadCard(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: text.isEmpty || text == 'No bio added yet'
                    ? Colors.grey.shade400
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyBioField(BuildContext context) {
    // Clean HTML tags from the text
    String cleanText = value;
    if (value.contains('<p>') || value.contains('</p>')) {
      cleanText = value.replaceAll('<p>', '').replaceAll('</p>', '');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        const SizedBox(height: 8),
        _buildInfoCard(
          context,
          text: cleanText.isEmpty ? 'No bio added yet' : cleanText,
          isMultiline: true,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
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

  Widget _buildInfoCard(
    BuildContext context, {
    required String text,
    Widget? leading,
    bool isMultiline = false,
  }) {
    return ShadCard(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(BuildContext context) {
    // Get icon background color based on icon type
    Color iconBgColor = _getIconBackgroundColor(icon);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        const SizedBox(height: 8),
        _buildInfoCard(
          context,
          text: value,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
    );
  }

  Color _getIconBackgroundColor(IconData icon) {
    if (icon == Icons.business) {
      return Colors.red.shade400; // Brand name
    } else if (icon == Icons.email) {
      return Colors.red.shade400; // Email
    } else if (icon == Icons.alternate_email) {
      return Colors.purple.shade400; // Username
    } else if (icon == Icons.category) {
      return Colors.red.shade400; // Industry
    } else {
      return ShadColors.primary.withOpacity(0.8); // Default
    }
  }
}
