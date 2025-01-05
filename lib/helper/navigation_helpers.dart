import 'package:flutter/material.dart';
import 'package:flutterApp/screens/homeScreen.dart';

void onWeatherButtonPressed(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
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
        var scaleTransform = Matrix4.identity()..scale(scaleAnimation.value);
        return Transform(
          transform: scaleTransform,
          alignment: Alignment.topLeft,
          child: FadeTransition(
            opacity: opacityAnimation,
            child: child,
          ),
        );
      },
    ),
  );
}
