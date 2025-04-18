import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ContractDetailsStep extends StatefulWidget {
  @override
  _ContractDetailsStepState createState() => _ContractDetailsStepState();
}

class _ContractDetailsStepState extends State<ContractDetailsStep> {
  DateTime? _selectedDate;
  String _currency = 'USD';

  final List<String> _postTypes = ['Reel', 'Carousel', 'Post'];
  final List<String> _selectedPostTypes = [];
  bool _confirmDetails = false;
  bool _acceptTerms = false;

  void _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contract Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // Post Type Row
        const Text(
          'Post Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 10,
          children: _postTypes.map((type) {
            return FilterChip(
              label: Text(type),
              selected: _selectedPostTypes.contains(type),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedPostTypes.add(type);
                  } else {
                    _selectedPostTypes.remove(type);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 15),

        // Delivery Date Picker
        const Text(
          'Delivery Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: AbsorbPointer(
            child: ShadInputFormField(
              placeholder: Text(
                _selectedDate == null
                    ? 'DD / MM / YYYY'
                    : '${_selectedDate!.day} / ${_selectedDate!.month} / ${_selectedDate!.year}',
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Budget Input with Currency Selection
        const Text(
          'Budget',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: ShadInputFormField(
                placeholder: const Text('Enter amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: _currency,
              underline: Container(),
              onChanged: (String? newValue) {
                setState(() {
                  _currency = newValue!;
                });
              },
              items: <String>['USD', 'EUR', 'GBP', 'INR']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Additional Requirements Input
        const Text(
          'Content Guidelines',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        ShadInputFormField(
          placeholder: const Text('Enter any additional requirements'),
          maxLines: 3,
        ),
        const SizedBox(height: 15),

        // Terms and Conditions
        const Text(
          'Please review the contract details carefully before sending. Make sure all information is correct and that you are comfortable with the terms and conditions.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),

        // Confirmation Checkboxes using ShadCheckbox
        const SizedBox(height: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadCheckbox(
              value: _confirmDetails,
              onChanged: (value) {
                setState(() {
                  _confirmDetails = value;
                });
              },
              label: const Text('I confirm all details are correct'),
            ),
            const SizedBox(height: 5),
            ShadCheckbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value;
                });
              },
              label: const Text('I accept all terms and conditions'),
            ),
          ],
        ),
      ],
    );
  }
}
