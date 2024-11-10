import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutterApp/Screens/mapScreen.dart';
import 'package:flutterApp/bottom/profile.dart';
import 'package:flutterApp/pages/camera.dart';
import 'package:flutterApp/pages/dulich.dart';



class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget> pages;

  late Map Homepage;
  late Dulich dulich;
  late Profile profile;
  late Camera camera;
  int currentTabIndex = 0;

  @override
  void initState() {
    Homepage =  Map();
    dulich = const Dulich();
    profile = const Profile();
    camera = const Camera();

    pages = [Homepage, dulich,camera, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 65,
          backgroundColor: const Color(0xfff2f2f2),
          color: const Color.fromARGB(255, 7, 157, 226),
          animationDuration: const Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: const [
            Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.beach_access_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
            ),
             Icon(
              Icons.person_2_outlined,
              color: Colors.white,
            ),
          
          ]),
          body: pages[currentTabIndex],
    );
  }
}
