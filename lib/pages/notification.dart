import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutterApp/bottom/bottomnav.dart';

class NotificationCus extends StatefulWidget {
  const NotificationCus({super.key});

  @override
  State<NotificationCus> createState() => _NotificationCusState();
}

class _NotificationCusState extends State<NotificationCus> {
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Thông báo 1',
      'content': 'Nội dung của thông báo 1 dài hơn tí đi',
      'img': 'assets/images/traffic_jam.png',
      'status': 'sent',
      'isRead': false,
      'timestamp': DateTime.now().subtract(Duration(minutes: 10)),
      'distance': '5.3 km',
      'longitude': 106.6926, // Example longitude
      'latitude': 16.7626, // Example latitude
    },
    {
      'title': 'Thông báo 2',
      'content': 'Nội dung của thông báo 2.',
      'img': 'assets/images/traffic_jam.png',
      'status': 'read',
      'isRead': true,
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      'distance': '2.8 km',
      'longitude': 106.6957,
      'latitude': 10.7670,
    },
  ];

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A'; // Return a placeholder if dateTime is null
    }
    return DateFormat('HH:mm dd/MM/yyyy')
        .format(dateTime); // Format the date if it's not null
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
          itemCount: notifications.length,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final isRead = notification['isRead'] ?? false;

            return GestureDetector(
              onTap: () {
                final bottomNavState =
                    context.findAncestorStateOfType<BottomNavState>();
                if (bottomNavState != null) {
                  bottomNavState.navigateToMap(
                    notification['longitude'],
                    notification['latitude'],
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
                              notification['img']!,
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
                            notification['title']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            notification['content']!,
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
                                'Distance: ${notification['distance']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                formatDate(notification['timestamp']),
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
                    SizedBox(
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
