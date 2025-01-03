import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final VoidCallback onPressed;
  final double top; // Vị trí tính từ trên cùng
  final double left; // Vị trí tính từ trái

  const WeatherIcon({
    Key? key,
    required this.onPressed,
    this.top = 160, // Giá trị mặc định
    this.left = 20, // Giá trị mặc định
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: top,
          left: left,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.cloudy_snowing,
                size: 30,
                color: Colors.white,
              ),
              onPressed: onPressed,
            ),
          ),
        ),
      
      ],
    );
  }
}
