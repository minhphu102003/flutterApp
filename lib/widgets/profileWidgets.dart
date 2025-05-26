import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterApp/widgets/support_widget.dart';

class AvatarPicker extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onImagePick;

  const AvatarPicker({
    super.key,
    required this.selectedImage,
    required this.onImagePick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onImagePick,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: selectedImage != null
              ? Image.file(selectedImage!, height: 150, width: 150, fit: BoxFit.cover)
              : const Icon(Icons.account_circle, size: 150.0, color: Colors.grey),
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24.0),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppWidget.lightTextFeildStyle()),
                  Text(value, style: AppWidget.semiboldTextFeildStyle()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Material(
          elevation: 3.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, size: 24.0),
                const SizedBox(width: 10.0),
                Text(label, style: AppWidget.semiboldTextFeildStyle()),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
