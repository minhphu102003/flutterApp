import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/mapScreen.dart';
import 'package:provider/provider.dart';

import './provider/weatherProvider.dart';
import 'Screens/homeScreen.dart';
import 'Screens/sevenDayForecastDetailScreen.dart';

void main(){
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget{
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
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
        ),
        home: MapScreen(),
        onGenerateRoute: (setting){
          final argument = setting.arguments;
          if(setting.name == SevenDayForecastDetail.routeName){
            return PageRouteBuilder(
              settings: setting,
              pageBuilder: (_,__,___) => SevenDayForecastDetail(
                initialIndex: argument == null ? 0 : argument as int,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => CupertinoPageTransition(
                primaryRouteAnimation: animation,
                secondaryRouteAnimation: secondaryAnimation,
                linearTransition: false,
                child: child,
              ),
            );
          }
          return MaterialPageRoute(builder: (_) => HomeScreen());
        },
      ),
    );
  }
}