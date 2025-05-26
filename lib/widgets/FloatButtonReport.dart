import 'package:flutter/material.dart';

class FloatingReportButton extends StatefulWidget {
  final VoidCallback changeScreen;
  final VoidCallback openCamera;
  final VoidCallback poststatus;
  final VoidCallback changeHidden;

  final double bottom;
  final double left;

  const FloatingReportButton({
    super.key,
    required this.changeScreen,
    required this.openCamera,
    required this.poststatus,
    required this.changeHidden,
    this.left = 10,
    this.bottom = 60,
  });

  @override
  _FloatingReportButtonState createState() => _FloatingReportButtonState();
}

class _FloatingReportButtonState extends State<FloatingReportButton> {
  bool _isHidden = true;

  void toggleHidden() {
    setState(() {
      _isHidden = !_isHidden;
    });
    widget.changeHidden();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Button 1
        Positioned(
          bottom: widget.bottom,
          left: widget.left,
          child: FloatingActionButton(
            onPressed: widget.changeScreen,
            heroTag: "report_traffic",
            child: const Icon(Icons.camera_enhance_outlined),
          ),
        ),
        // Button 2
        Positioned(
          bottom: widget.bottom + 65,
          left: widget.left,
          child: FloatingActionButton(
            onPressed: widget.openCamera,
            heroTag: "show_direction",
            child: const Icon(Icons.directions),
          ),
        ),
        // Button 3
        Positioned(
          bottom: widget.bottom + 130,
          left: widget.left,
          child: FloatingActionButton(
            onPressed: widget.poststatus,
            heroTag: "post_status",
            child: const Icon(Icons.warning),
          ),
        ),
        // Button 4
        Positioned(
          bottom: widget.bottom + 195,
          left: widget.left,
          child: FloatingActionButton(
            onPressed: toggleHidden,
            heroTag: "hidden_image",
            child: Icon(
              _isHidden ? Icons.hide_image : Icons.image,
            ),
          ),
        ),
      ],
    );
  }
}
