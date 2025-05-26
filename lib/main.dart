import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/weatherProvider.dart';
import 'screens/homeScreen.dart';
import 'screens/bottomnav.dart';

void main() {
  runApp(
    const MyApp(),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Weatherprovider(),
      child: MaterialApp(
          title: 'Flutter Weather',
          debugShowCheckedModeBanner: false,
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
          home: const BottomNav(),

          onGenerateRoute: (setting) {
            final argument = setting.arguments;
            if (setting.name == SevenDayForecastDetail.routeName) {
              return PageRouteBuilder(
                settings: setting,
                pageBuilder: (_, __, ___) => SevenDayForecastDetail(
                  initialIndex: argument == null ? 0 : argument as int,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = 0.0;
                  const end = 1.0;
                  const curve = Curves.easeInOut;

                  var scaleAnimation =
                      Tween<double>(begin: begin, end: end).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  );

                  var opacityAnimation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: curve,
                    ),
                  );

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

            if (setting.name == MapScreen.routeName) {
              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MapScreen(),
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
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          }),
    );
  }
}
class MapScreen extends StatelessWidget {
  static const routeName = '/map';

  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: const Center(child: Text('Map Screen Content')),
    );
  }
}

class SevenDayForecastDetail extends StatelessWidget {
  static const routeName = '/sevenDayForecastDetail';

  final int initialIndex;

  const SevenDayForecastDetail({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('7-Day Forecast'),
      ),
      body: Center(
        child: Text('Forecast for Day $initialIndex'),
      ),
    );
  }
}
