import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String formatDate(DateTime? dateTime) {
  if (dateTime == null) {
    return 'N/A'; // Return a placeholder if dateTime is null
  }
  // Cộng thêm 7 giờ trước khi format
  final adjustedDateTime = dateTime.add(const Duration(hours: 7));
  return DateFormat('HH:mm dd/MM/yyyy').format(adjustedDateTime);
}
    @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.notifications); // Khởi tạo danh sách từ widget.notifications
  }
  void addNotification(TrafficNotification notification){
    setState(() {
      _notifications.insert(0, notification); // Thêm thông báo mới vào đầu danh sách
    });
  }

  void addNotificationsInit(List<TrafficNotification> notifications) {
    setState(() {
      _notifications = List.from(notifications); // Gán danh sách mới
    });
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            final isRead = notification.isRead;

            return GestureDetector(
              onTap: () {
                final bottomNavState =
                    context.findAncestorStateOfType<BottomNavState>();
                if (bottomNavState != null) {
                  bottomNavState.navigateToMap(
                    notification.longitude,
                    notification.latitude,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2.0),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              notification.title.startsWith('T')
                                  ? 'assets/images/traffic_jam.png'
                                  : notification.title.startsWith('F')
                                      ? 'assets/images/flood.png'
                                      : notification.title.startsWith('R')
                                          ? 'assets/images/roadWork.png'
                                          : 'assets/images/accident.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
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
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            notification.content,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          // Row for Distance and Time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Distance: ${notification.distance}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                formatDate(notification.timestamp),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(height: 8);
          },
        ),
      ),
    );
  }
}