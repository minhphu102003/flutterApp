import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterApp/Screens/mapScreen.dart';
import 'package:flutterApp/login/sign/login.dart';
import 'package:flutterApp/login/sign/sign.dart';
import 'package:flutterApp/bottom/bottomnav.dart';
import 'package:flutterApp/bottom/key.dart';
import 'package:flutterApp/bottom/profile.dart';
import 'package:flutterApp/pages/dulich.dart';
import 'package:provider/provider.dart';
import './provider/weatherProvider.dart';
import 'Screens/homeScreen.dart';
import 'Screens/sevenDayForecastDetailScreen.dart';
import 'dart:convert'; // Thêm thư viện này để dùng json.decode

void main() {
  // Hàm main khởi chạy ứng dụng Flutter
  runApp(
    MyApp(),
  );
}

// Widget chính của ứng dụng
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Cung cấp đối tượng WeatherProvider cho các widget con
      create: (context) => Weatherprovider(),
      child: MaterialApp(
          title: 'Flutter Weather',
          debugShowCheckedModeBanner: false,
          // Cấu hình các thông số giao diện như theme, color, font, v.v.
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.blue),
              elevation: 0,
            ),
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
          ),
          // Màn hình khởi đầu của ứng dụng là BottomNav
          home: Sign(),
          
          // Cấu hình cho việc điều hướng trong ứng dụng
          onGenerateRoute: (setting) {
            // Lấy argument truyền vào cho route
            final argument = setting.arguments;
            print(setting.name);
            
            // Điều hướng đến màn hình chi tiết dự báo thời tiết 7 ngày
            if (setting.name == SevenDayForecastDetail.routeName) {
              return PageRouteBuilder(
                settings: setting,
                pageBuilder: (_, __, ___) => SevenDayForecastDetail(
                  initialIndex: argument == null ? 0 : argument as int,
                ),
                // Cấu hình hiệu ứng chuyển đổi màn hình
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = 0.0;
                  const end = 1.0;
                  const curve = Curves.easeInOut;

                  // Hoạt ảnh phóng to màn hình
                  var scaleAnimation =
                      Tween<double>(begin: begin, end: end).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  );

                  // Hoạt ảnh mờ dần màn hình
                  var opacityAnimation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  );

                  // Kết hợp hai hoạt ảnh để tạo hiệu ứng chuyển đổi
                  return ScaleTransition(
                    scale: scaleAnimation,
                    child: FadeTransition(
                      opacity: opacityAnimation,
                      child: child,
                    ),
                  );
                },
              );
            }

            // Điều hướng đến màn hình bản đồ
            if (setting.name == MapScreen.routeName) {
              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MapScreen(),
                // Cấu hình hiệu ứng chuyển đổi màn hình
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = 0.0;
                  const end = 1.0;
                  const curve = Curves.easeInOut;

                  // Hoạt ảnh phóng to màn hình
                  var scaleAnimation =
                      Tween<double>(begin: begin, end: end).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  );

                  // Hoạt ảnh mờ dần màn hình
                  var opacityAnimation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  );

                  // Kết hợp hai hoạt ảnh để tạo hiệu ứng chuyển đổi
                  return ScaleTransition(
                    scale: scaleAnimation,
                    child: FadeTransition(
                      opacity: opacityAnimation,
                      child: child,
                    ),
                  );
                },
              );
            }

            // Mặc định điều hướng về HomeScreen nếu không có route phù hợp
            return MaterialPageRoute(builder: (_) => HomeScreen());
          }),
    );
  }
}

// Màn hình MapScreen với routeName được định nghĩa
class MapScreen extends StatelessWidget {
  static const routeName = '/map'; // Thêm routeName cho MapScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
      ),
      body: Center(child: Text('Map Screen Content')),
    );
  }
}

// Đảm bảo màn hình SevenDayForecastDetail cũng có routeName
class SevenDayForecastDetail extends StatelessWidget {
  static const routeName = '/sevenDayForecastDetail';

  final int initialIndex;

  SevenDayForecastDetail({required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('7-Day Forecast'),
      ),
      body: Center(
        child: Text('Forecast for Day $initialIndex'),
      ),
    );
  }
}
