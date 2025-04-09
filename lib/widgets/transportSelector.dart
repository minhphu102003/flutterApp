import 'package:flutter/material.dart';
import 'package:flutterApp/constants/transportMode.dart';

class TransportSelector extends StatelessWidget {
  final TransportMode selectedMode;
  final void Function(TransportMode) onModeSelected;

  const TransportSelector({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(Icons.directions_car, TransportMode.car),
          const SizedBox(width: 10),
          _buildIcon(Icons.directions_bus, TransportMode.bus),
          const SizedBox(width: 10),
          _buildIcon(Icons.motorcycle, TransportMode.motorcycle),
          const SizedBox(width: 10),
          _buildIcon(Icons.directions_bike, TransportMode.bike),
          const SizedBox(width: 10),
          _buildIcon(Icons.directions_walk, TransportMode.walk),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData iconData, TransportMode mode) {
    final bool isSelected = selectedMode == mode;

    return GestureDetector(
      onTap: () => onModeSelected(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: isSelected ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }
}
