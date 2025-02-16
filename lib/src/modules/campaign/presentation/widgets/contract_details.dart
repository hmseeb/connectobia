import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ContractDetailsStep extends StatefulWidget {
  @override
  _ContractDetailsStepState createState() => _ContractDetailsStepState();
}

class _ContractDetailsStepState extends State<ContractDetailsStep> {
  DateTime? _selectedDate;
  double _amount = 0;
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

        // Post Type Checkboxes
        const Text(
          'Post Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ..._postTypes.map((type) {
          return CheckboxListTile(
            title: Text(type),
            value: _selectedPostTypes.contains(type),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedPostTypes.add(type);
                } else {
                  _selectedPostTypes.remove(type);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
        const SizedBox(height: 10),

        // Delivery Date Picker
        const Text(
          'Delivery',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: AbsorbPointer(
            child: ShadInputFormField(
              label: const Text('Select Date'),
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
                    _amount = double.tryParse(value) ?? 0;
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

        // Terms and Conditions
        const Text(
          'Please review the contract details carefully before sending. Make sure all information is correct and that you are comfortable with the terms and conditions.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 10),

        CheckboxListTile(
          title: const Text('I confirm all details are correct'),
          value: _confirmDetails,
          onChanged: (bool? value) {
            setState(() {
              _confirmDetails = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: const Text('I accept all terms and conditions'),
          value: _acceptTerms,
          onChanged: (bool? value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}
