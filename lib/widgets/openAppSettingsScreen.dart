import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class OpenAppSettingsScreen extends StatelessWidget {
  final VoidCallback onPermissionGranted;

  const OpenAppSettingsScreen({super.key, required this.onPermissionGranted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grant Permission")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await openAppSettings();
            await Future.delayed(const Duration(seconds: 1));

            final isGranted = await Permission.storage.isGranted;
            if (isGranted) {
              onPermissionGranted();
              Navigator.pop(context); 
            }
          },
          child: const Text("Open App Settings"),
        ),
      ),
    );
  }
}
