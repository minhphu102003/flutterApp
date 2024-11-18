import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutterApp/config.dart';

class MapDisplay extends StatelessWidget {
  final LatLng currentLocation;
  final List<LatLng> routePolyline;
  final MapController mapController;
  final bool mapReady;
  final void Function() onMapReady;

  const MapDisplay({
    Key? key,
    required this.currentLocation,
    required this.routePolyline,
    required this.mapController,
    required this.mapReady,
    required this.onMapReady,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String api = Config.api_mapbox_key;
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: 16.0,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$api",
        ),
        if (routePolyline.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(points: routePolyline, strokeWidth: 4.0, color: Colors.blue)
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: currentLocation,
              width: 30.0,
              height: 30.0,
              child: const Icon(Icons.location_on, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }
}
