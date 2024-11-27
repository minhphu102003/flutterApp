import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutterApp/Screens/mapScreen.dart';
import 'package:flutterApp/pages/profile.dart';
import 'package:flutterApp/pages/camera.dart';
import 'package:flutterApp/pages/dulich.dart';
import 'package:flutterApp/pages/notification.dart';
import 'package:flutterApp/helper/webSocket.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterApp/helper/user.dart';
import 'package:flutterApp/models/notification.dart';
import 'package:flutterApp/helper/location.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => BottomNavState();
}

class BottomNavState extends State<BottomNav> {
  late List<Widget> pages;

  late MapScreen homepage;
  late Dulich dulich;
  late Profile profile;
  late Camera camera;
  late NotificationCus notification;
  late WebSocketService _webSocketService;

  // Callback function to add new notification
  void addNewNotification(TrafficNotification newNotification) {
    setState(() {
      if (currentLatitude != null && currentLongitude != null) {
        newNotification.distance = "${calculateDistances(
          currentLatitude!,
          currentLongitude!,
          newNotification.latitude,
          newNotification.longitude,
        ).toStringAsFixed(1)} km";
        // Add new notification to the list using the GlobalKey
        notificationKey.currentState?.addNotification(newNotification);  // Correct usage of notificationKey
        print(newNotification);
        newNotificationCount++;  // Increment the count of new notifications
      }
    });
  }

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  GlobalKey<MapScreenState> mapKey = GlobalKey<MapScreenState>();
  GlobalKey<NotificationCusState> notificationKey = GlobalKey<NotificationCusState>(); 

  int currentTabIndex = 0;
  int newNotificationCount = 0;
  List<TrafficNotification> notifications = [];
  double? currentLatitude;
  double? currentLongitude;

  void navigateToMap(double longitude, double latitude) {
    mapKey.currentState?.updateLocation(longitude, latitude);
    setState(() {
      currentTabIndex = 0;
    });
    _bottomNavigationKey.currentState?.setPage(currentTabIndex);
  }

  void onLocationChanged(double longitude, double latitude) {
    setState(() {
      currentLongitude = longitude;
      currentLatitude = latitude;
    });
    sendLocationUpdate(longitude, latitude);
  }

  Future<void> sendLocationUpdate(double longitude, double latitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String uniqueId = await getUniqueId();
    Map<String, dynamic> payload = {
      'type': 'update location',
      'token': token ?? '',
      'uniqueid': uniqueId,
      'latitude': latitude,
      'longitude': longitude,
    };
    _webSocketService.sendMessage(json.encode(payload));
  }

  @override
  void initState() {
    super.initState();
    homepage = MapScreen(key: mapKey, onLocationChanged: onLocationChanged);
    dulich = const Dulich();
    profile = const Profile();
    camera = const Camera();

    // Pass notificationKey to NotificationCus so its state can be accessed
    notification = NotificationCus(
      key: notificationKey,  // Pass the GlobalKey here
      notifications: notifications,  // Pass notifications list
    );

    pages = [homepage, dulich, camera, notification, profile];
    _webSocketService = WebSocketService();
    _webSocketService.connect('ws://10.0.2.2:8000');
    _webSocketService.onNotificationReceived = (TrafficNotification newNotification) {
      addNewNotification(newNotification);  // Call the callback to add new notification
    };
    _webSocketService.sendMessage('Client connected');
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        height: 65,
        backgroundColor: Colors.transparent,
        color: const Color.fromARGB(255, 7, 157, 226),
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
            if (index == 3) {
              newNotificationCount = 0; // Reset thông báo khi vào Notification
            }
          });
        },
        items: [
          const Icon(Icons.home_outlined, color: Colors.white),
          const Icon(Icons.beach_access_outlined, color: Colors.white),
          const Icon(Icons.camera_alt_outlined, color: Colors.white),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_on_outlined, color: Colors.white),
              if (newNotificationCount > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$newNotificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const Icon(Icons.person_2_outlined, color: Colors.white),
        ],
      ),
      body: IndexedStack(
        index: currentTabIndex,
        children: pages, // Giữ trạng thái của tất cả các màn hình
      ),
    );
  }
}