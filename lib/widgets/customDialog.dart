import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget{
  final String title;
  final String message;
  final IconData typeIcon;
  final Color color;
  final VoidCallback onDialogClose;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.typeIcon,
    required this.color,
    required this.onDialogClose,
  });

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog>{
  late Color buttonColor;

  @override
  void initState() {
    super.initState();
    buttonColor = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.typeIcon, color: widget.color),
          const SizedBox(width: 8),
          Text(widget.title),
        ],
      ),
      content: Text(widget.message),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              buttonColor = Colors.grey; // Thay đổi màu sắc khi button được nhấn
            });
            Navigator.of(context).pop();
            widget.onDialogClose();
          },
          style: TextButton.styleFrom(
            foregroundColor: buttonColor, // Sử dụng màu động cho button
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}