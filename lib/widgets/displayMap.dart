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
  final double markerSize;
  final void Function(TapPosition, LatLng) onMapTap;
  final List<Marker> additionalMarkers; // Danh sách marker tùy chỉnh

  const MapDisplay({
    Key? key,
    required this.currentLocation,
    required this.routePolyline,
    required this.mapController,
    required this.mapReady,
    required this.onMapReady,
    required this.onMapTap,
    this.additionalMarkers = const [], // Khởi tạo danh sách rỗng
    this.markerSize = 30.0,
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
        onTap: onMapTap,
      ),
      children: [
        TileLayer(
          urlTemplate:
              "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$api",
        ),
        if (routePolyline.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePolyline,
                strokeWidth: 4.0,
                color: Colors.blue,
              )
            ],
          ),
        MarkerLayer(
          markers: [
            // Marker mặc định tại vị trí hiện tại
            Marker(
              point: currentLocation,
              width: markerSize,
              height: markerSize,
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: markerSize * 0.6,
              ),
            ),
            // Marker tùy chỉnh từ danh sách
            ...additionalMarkers,
          ],
        ),
      ],
    );
  }
}
