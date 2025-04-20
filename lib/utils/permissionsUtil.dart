import 'package:flutterApp/widgets/openAppSettingsScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

Future<void> requestPermissions(BuildContext context, VoidCallback onGranted) async {
  final status = await Permission.videos.request();

  if (status.isGranted) {
    onGranted();
  } else if (status.isPermanentlyDenied) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpenAppSettingsScreen(
          onPermissionGranted: onGranted,
        ),
      ),
    );
  } else if (status.isDenied) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Denied"),
        content: const Text("Media access permission is required to continue."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}