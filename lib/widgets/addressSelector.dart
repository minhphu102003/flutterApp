import 'package:flutter/material.dart';

class AddressSelector extends StatelessWidget {
  final String selectedCity;
  final List<String> cities;
  final ValueChanged<String> onCityChanged;

  const AddressSelector({
    super.key,
    required this.selectedCity,
    required this.cities,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: const Icon(Icons.location_on, color: Colors.black),
          ),
          title: const Text(
            'Your Address',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: selectedCity,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey[400]!), // Viền nhạt hơn
                ),
                contentPadding: const EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: 10,
                    right: 10), // Giữ padding trái và phải
              ),
              dropdownColor: Colors.grey[200],
              iconEnabledColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              items: cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 135, 134, 134))),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onCityChanged(value);
              },
            ),
          ),
        ),
      ),
    );
  }
}
