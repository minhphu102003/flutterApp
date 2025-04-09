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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 94, 93, 93),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1), // Nhẹ nhàng
              ),
              child: const Icon(Icons.location_on, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Address',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white, // 👈 Màu trắng
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.transparent, // 👈 Màu nền dropdown
                        value: selectedCity,
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        items: cities.map((city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onCityChanged(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
