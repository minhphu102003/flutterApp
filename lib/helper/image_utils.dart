import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<String?> validateImage(XFile pickedFile) async {
  const List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'gif'];

  // Kiểm tra định dạng file
  final String fileExtension = pickedFile.path.split('.').last.toLowerCase();
  if (!allowedFormats.contains(fileExtension)) {
    return 'Only images (JPEG, JPG, PNG, GIF) are allowed.';
  }
  // Ảnh hợp lệ
  return null;
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Notification'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
