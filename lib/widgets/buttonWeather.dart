import 'package:flutter/material.dart';
import '../theme/colors.dart';

class WeatherButton extends StatelessWidget {
  final VoidCallback onPressed;

  const WeatherButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.15,  // 20% from the top
      left: 10.0,  // Padding from the left
      child: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: onPressed,
        child: const Icon(Icons.cloud, color: Colors.white),  // Weather icon
      ),
    );
  }
}