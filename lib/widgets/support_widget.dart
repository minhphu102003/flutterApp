import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle boldTextFeildStyle() {
    return const TextStyle(
        color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold);
  }

  static TextStyle lightTextFeildStyle() {
    return const TextStyle(
        color: Colors.black54, fontSize: 18.0, fontWeight: FontWeight.w500);
  }

  static TextStyle semiboldTextFeildStyle() {
    return const TextStyle(
        color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold);
  }
}
