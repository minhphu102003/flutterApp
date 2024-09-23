import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/mapSample.dart';
import 'package:flutter_application_1/widgets/buttonWeather.dart';
import 'package:flutter_application_1/Screens/homeScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import '../widgets/searchBar.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/mapScreen';
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FloatingSearchBarController fsc = FloatingSearchBarController();
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(44.34, 10.99);
  bool _isSearchBarOpened = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onWeatherButtonPressed() {
    // Lấy kích thước màn hình
    final screenSize = MediaQuery.of(context).size;
    // Tính toán vị trí của button
    final buttonOffset = Offset(10.0, screenSize.height * 0.15);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          // Điều chỉnh vị trí bắt đầu phóng theo buttonOffset
          var scaleAnimation = Tween<double>(begin: begin, end: end).animate(
            CurvedAnimation(
              parent: animation,
              curve: curve,
            ),
          );

          var opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: curve,
            ),
          );

          // Tính toán offset cho màn hình mới
          var scaleTransform = Matrix4.identity()
            ..scale(scaleAnimation.value);

          return Transform(
            transform: scaleTransform,
            alignment:
                Alignment.topLeft, // Hoặc điều chỉnh để phù hợp với yêu cầu
            child: FadeTransition(
              opacity: opacityAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _toggleSearchBar(bool isOpen) {
    setState(() {
      _isSearchBarOpened = isOpen; // Update the state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MapSample(),
          SearchBarBar(
            fsc: fsc,
            onToggle: _toggleSearchBar, // Gửi callback cho SearchBarBar
          ),
          if (!_isSearchBarOpened)
            WeatherButton(onPressed: _onWeatherButtonPressed),
        ],
      ),
    );
  }
}
