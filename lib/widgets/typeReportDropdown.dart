import 'package:flutter/material.dart';

class TypeReportDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const TypeReportDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder( 
            builder: (context, constraints) {
              return DropdownButtonFormField<String>(
                value: value,
                onChanged: onChanged,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Type Report',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                ),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down),
                borderRadius: BorderRadius.circular(10),
                alignment: Alignment.centerLeft,
                items: const [
                  'Traffic Jam',
                  'Flood',
                  'Accident',
                  'Road Work',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  );
                }).toList(),
                menuMaxHeight: 300,
              );
            },
          ),
        ),
      ],
    );
  }
}
