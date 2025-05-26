import 'package:flutter/material.dart';
import 'package:flutterApp/services/notificationService.dart';
import 'package:flutterApp/widgets/notification/notificationTile.dart';
import 'package:flutterApp/screens/bottomnav.dart';
import 'package:flutterApp/models/notification.dart';

class NotificationCus extends StatefulWidget {
  final List<TrafficNotification> notifications;
  const NotificationCus({super.key, this.notifications = const []});

  @override
  State<NotificationCus> createState() => NotificationCusState();
}

class NotificationCusState extends State<NotificationCus> {
  late List<TrafficNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.notifications);
  }

  void addNotification(TrafficNotification notification) {
    setState(() {
      _notifications.insert(0, notification);
    });
  }

  void addNotificationsInit(List<TrafficNotification> notifications) {
    setState(() {
      _notifications = List.from(notifications);
    });
  }

  void updateAndNavigate(
      BuildContext context, TrafficNotification notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = TrafficNotification(
          id: notification.id,
          title: notification.title,
          content: notification.content,
          status: notification.status,
          isRead: true,
          timestamp: notification.timestamp,
          distance: notification.distance,
          longitude: notification.longitude,
          latitude: notification.latitude,
          img: notification.img,
        );
      }
    });

    NotificationService().updateNotificationStatus(notification.id);

    final bottomNavState = context.findAncestorStateOfType<BottomNavState>();
    if (bottomNavState != null) {
      bottomNavState.navigateToMap(
        notification.longitude,
        notification.latitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView.separated(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return NotificationTile(
              notification: notification,
              onTap: () => updateAndNavigate(context, notification),
            );
          },
          separatorBuilder: (context, index) => const Divider(height: 8),
        ),
      ),
    );
  }
}
