import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Widget mẫu cho bản đồ
class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  // Trình điều khiển cho Google Map
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // Vị trí và mức zoom mặc định
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.048535, 108.201686),  // Tọa độ vị trí
    zoom: 15,  // Mức zoom
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        // Đặt loại bản đồ là bình thường
        mapType: MapType.normal,  
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          // Hoàn thành trình điều khiển khi bản đồ được tạo
          _controller.complete(controller);
        },
      ),
    );
  }
}
