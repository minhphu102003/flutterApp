import 'package:flutter/material.dart';

class FloatingReportButton extends StatelessWidget {
  final VoidCallback changeScreen;
  final VoidCallback openCamera;
  final VoidCallback poststatus;

  final double bottom;
  final double left;

  const FloatingReportButton({
    Key? key,
    required this.changeScreen,
    required this.openCamera,
    required this.poststatus,
    this.left = 10,
    this.bottom = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Button 1
        Positioned(
          bottom: bottom,
          left: left,
          child: FloatingActionButton(
            onPressed: changeScreen,
            heroTag: "report_traffic",
            child: const Icon(Icons.camera_enhance_outlined),
          ),
        ),
        // Button 2
        Positioned(
          bottom: bottom + 70, // Adjust to stack the buttons vertically
          left: left,
          child: FloatingActionButton(
            onPressed: openCamera,
            heroTag: "show_direction",
            child: const Icon(Icons.directions),
          ),
        ),

        Positioned(
          bottom: bottom + 140, // Adjust to stack the buttons vertically
          left: left,
          child: FloatingActionButton(
            onPressed: poststatus,
            heroTag: "post_status",
            child: const Icon(Icons.warning),
          ),
        ),
      ],
    );
  }
}
