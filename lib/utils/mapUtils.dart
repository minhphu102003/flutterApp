import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

List<Marker> buildStartEndMarkers({
  required LatLng? startPosition,
  required LatLng? endPosition,
}) {
  final List<Marker> markers = [];

  if (startPosition != null) {
    markers.add(
      Marker(
        point: startPosition,
        width: 30,
        height: 30,
        child: const Icon(
          Icons.location_on,
          color: Colors.green,
          size: 40,
        ),
      ),
    );
  }

  if (endPosition != null) {
    markers.add(
      Marker(
        point: endPosition,
        width: 30,
        height: 30,
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 40,
        ),
      ),
    );
  }

  return markers;
}
