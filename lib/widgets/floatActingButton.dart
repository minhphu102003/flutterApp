import 'package:flutter/material.dart';

class FloatingActionButtons extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCurrentLocation;

  // Các tham số để định vị vị trí
  final double bottom;
  final double right;

  const FloatingActionButtons({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCurrentLocation,
    this.bottom = 50.0, // Vị trí mặc định cách cạnh dưới 50px
    this.right = 10.0,  // Vị trí mặc định cách cạnh phải 10px
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: bottom,
          right: right,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "zoom_in",
                onPressed: onZoomIn,
                child: const Icon(Icons.zoom_in),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "zoom_out",
                onPressed: onZoomOut,
                child: const Icon(Icons.zoom_out),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "current_location",
                onPressed: onCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
