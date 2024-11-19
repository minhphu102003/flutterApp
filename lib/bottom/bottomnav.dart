import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutterApp/Screens/mapScreen.dart';
import 'package:flutterApp/bottom/profile.dart';
import 'package:flutterApp/pages/camera.dart';
import 'package:flutterApp/pages/dulich.dart';
import 'package:flutterApp/pages/notification.dart';
import 'package:flutterApp/Screens/reportScreen.dart';

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

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  GlobalKey<MapScreenState> mapKey = GlobalKey<MapScreenState>();

  int currentTabIndex = 0;
  int newNotificationCount = 3;
  bool isReportScreen = false; // Thêm biến này

  void navigateToMap(double longitude, double latitude) {
    mapKey.currentState?.updateLocation(longitude, latitude);
    setState(() {
      currentTabIndex = 0;
    });
    _bottomNavigationKey.currentState?.setPage(currentTabIndex);
  }

  void switchToReportScreen() {
    setState(() {
      isReportScreen = true;
    });
  }

  void returnToMainScreens() {
    setState(() {
      isReportScreen = false;
    });
  }

  @override
  void initState() {
    super.initState();
    homepage = MapScreen(
      key: mapKey,
      changeScreen: switchToReportScreen, // Gọi hàm này khi nhấn nút báo cáo
    );
    dulich = const Dulich();
    profile = const Profile();
    camera = const Camera();
    notification = const NotificationCus();

    pages = [homepage, dulich, camera, notification, profile];
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    bottomNavigationBar: isReportScreen
        ? null // Không hiển thị Bottom Navigation khi ở ReportScreen
        : CurvedNavigationBar(
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
    body: isReportScreen
        ? ReportScreen() // Hiển thị ReportScreen nếu `isReportScreen` là true
        : IndexedStack(
            index: currentTabIndex,
            children: pages, // Giữ trạng thái của tất cả các màn hình
          ),
    floatingActionButton: isReportScreen
        ? FloatingActionButton(
            onPressed: returnToMainScreens,
            child: const Icon(Icons.arrow_back),
          )
        : null, // Hiển thị nút trở lại nếu ở ReportScreen
  );
}

}
