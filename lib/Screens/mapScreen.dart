import 'package:flutter/material.dart';
import 'package:flutterApp/widgets/mapSample.dart';
import 'package:flutterApp/widgets/buttonWeather.dart';
import 'package:flutterApp/Screens/homeScreen.dart';
import 'package:flutterApp/bottom/bottomnav.dart';
import 'package:flutterApp/bottom/key.dart';
import 'package:flutterApp/bottom/profile.dart';
import 'package:flutterApp/widgets/support_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import '../widgets/searchBar.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/mapScreen'; // Đường dẫn cho việc điều hướng
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FloatingSearchBarController fsc = FloatingSearchBarController(); // Điều khiển cho thanh tìm kiếm
  late GoogleMapController mapController; // Điều khiển bản đồ
  final LatLng _center = const LatLng(44.34, 10.99); // Tọa độ trung tâm bản đồ
  bool _isSearchBarOpened = false; // Trạng thái của thanh tìm kiếm

  // Hàm gọi khi bản đồ được tạo
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller; // Lưu controller của bản đồ
  }

  // Hàm gọi khi nút thời tiết được nhấn
  void _onWeatherButtonPressed() {
    // Lấy kích thước màn hình
    final screenSize = MediaQuery.of(context).size;
    // Tính toán vị trí của button
    final buttonOffset = Offset(10.0, screenSize.height * 0.15);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
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
          var scaleTransform = Matrix4.identity()..scale(scaleAnimation.value);

          return Transform(
            transform: scaleTransform,
            alignment: Alignment.topLeft, // Hoặc điều chỉnh để phù hợp với yêu cầu
            child: FadeTransition(
              opacity: opacityAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  // Hàm để thay đổi trạng thái của thanh tìm kiếm
  void _toggleSearchBar(bool isOpen) {
    setState(() {
      _isSearchBarOpened = isOpen; // Cập nhật trạng thái
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MapSample(), // Hiển thị bản đồ
          SearchBarBar(
            fsc: fsc,
            onToggle: _toggleSearchBar, // Gửi callback cho SearchBarBar
          ),
          // Hiển thị nút thời tiết nếu thanh tìm kiếm chưa mở
          if (!_isSearchBarOpened)
            WeatherButton(onPressed: _onWeatherButtonPressed),
        ],
      ),
    );
  }
}