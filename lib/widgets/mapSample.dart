import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // Vị trí và zoom dựa trên URL của bạn
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(16.048535, 108.201686),  // Tọa độ từ URL
    zoom: 15,  // Mức zoom từ URL
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        // Sửa mapType thành normal
        mapType: MapType.satellite,  
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
