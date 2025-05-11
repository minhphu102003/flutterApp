import 'package:flutter/material.dart';
import 'package:flutterApp/models/notification.dart';

class NotificationImage extends StatelessWidget {
  final TrafficNotification notification;

  const NotificationImage({super.key, required this.notification});

  String _getImagePath(String title) {
    if (title.startsWith('T')) return 'assets/images/traffic_jam.png';
    if (title.startsWith('F')) return 'assets/images/flood.png';
    if (title.startsWith('R')) return 'assets/images/roadWork.png';
    return 'assets/images/accident.png';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2.0),
          ),
          child: ClipOval(
            child: Image.asset(
              _getImagePath(notification.title),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (!notification.isRead)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
