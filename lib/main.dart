import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/mapScreen.dart';
import 'package:provider/provider.dart';

import './provider/weatherProvider.dart';
import 'Screens/homeScreen.dart';
import 'Screens/sevenDayForecastDetailScreen.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
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
          home: MapScreen(),
          onGenerateRoute: (setting) {
            final argument = setting.arguments;
            print(setting.name);
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

            return MaterialPageRoute(builder: (_) => HomeScreen());
          }),
    );
  }
}
