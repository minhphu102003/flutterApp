import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LocationInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final VoidCallback onMapTap;

  const LocationInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.onMapTap,
  });

  @override
  State<LocationInputField> createState() => _LocationInputFieldState();
}

class _LocationInputFieldState extends State<LocationInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.black),
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                CupertinoIcons.location_solid,
                color: Colors.blue,
              ),
              onPressed: widget.onMapTap,
            ),
          ],
        ),
        if (_isFocused)
          Padding(
            padding: const EdgeInsets.only(left: 40.0, top: 6.0),
            child: GestureDetector(
              onTap: widget.onMapTap,
              child: const Row(
                children: [
                  Icon(Icons.touch_app, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Tap on the map to select a location',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
