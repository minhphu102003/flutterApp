import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/mapScreen.dart';
import 'package:provider/provider.dart';

import './provider/weatherProvider.dart';
import 'Screens/homeScreen.dart';
import 'Screens/sevenDayForecastDetailScreen.dart';

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
          // Màn hình khởi đầu của ứng dụng là MapScreen
          home: MapScreen(),
          
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
