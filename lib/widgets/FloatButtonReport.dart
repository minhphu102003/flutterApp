import 'package:flutter/material.dart';

class FloatingReportButton extends StatelessWidget{
  final VoidCallback changeScreen;

  final double bottom;
  final double left;
  const FloatingReportButton({
    Key? key,
    required this.changeScreen,
    this.left = 10,
    this.bottom = 50,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: bottom,
          left: left,
          child: FloatingActionButton(
            onPressed: changeScreen,
            heroTag: "report_traffic",
            child: const Icon(Icons.camera_enhance_outlined),
            )
          )
      ],
    );
  }
}