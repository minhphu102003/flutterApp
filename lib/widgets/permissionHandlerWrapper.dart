import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onPermissionGranted;

  const PermissionHandlerWrapper({
    super.key,
    required this.child,
    required this.onPermissionGranted,
  });

  @override
  State<PermissionHandlerWrapper> createState() => _PermissionHandlerWrapperState();
}

class _PermissionHandlerWrapperState extends State<PermissionHandlerWrapper> with WidgetsBindingObserver {
  bool _openedSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

@override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  if (state == AppLifecycleState.resumed && _openedSettings) {
    _openedSettings = false;

    await Future.delayed(const Duration(milliseconds: 5000));

    final isGranted = await Permission.storage.isGranted;
    if (isGranted) {
      widget.onPermissionGranted();
    } else {
      debugPrint("Permission still not granted.");
    }
  }
}

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();

    if (!status.isGranted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permission Denied'),
            content: const Text('You need to grant storage permission to continue.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // pop dialog trước
                  _openedSettings = true;
                  await openAppSettings(); // mở settings
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );
    } else {
      widget.onPermissionGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _requestPermissions,
      child: widget.child,
    );
  }
}
