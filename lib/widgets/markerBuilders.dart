import 'package:flutter/material.dart';
import 'package:flutterApp/models/camera.dart';
import 'package:flutterApp/models/notification.dart';
import 'package:flutterApp/models/place.dart';
import 'package:flutterApp/widgets/reportMarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

typedef ShowPlaceInfoCallback = void Function(BuildContext, Place);
typedef ShowYoutubeDialogCallback = void Function(BuildContext, String);

List<Marker> buildReportMarkers({
  required List<TrafficNotification> notifications,
  required int? selectedIndex,
  required double zoomLevel,
  required bool displayImage,
  required void Function(int index) onTap,
}) {
  return List.generate(notifications.length, (index) {
    final report = notifications[index];
    final isSelected = selectedIndex == index;
    final double baseSize = isSelected ? 50.0 : 36.0;
    const double scaleFactor = 1.2;
    final double scaledSize =
        baseSize * (zoomLevel / 15 * scaleFactor).clamp(0.5, 2.0);

    return Marker(
      point: LatLng(report.latitude, report.longitude),
      width: scaledSize,
      height: scaledSize,
      child: ReportMarkerWidget(
        zoom: zoomLevel,
        isSelected: isSelected,
        displayImage: displayImage,
        imageUrl: report.img,
        onTap: () => onTap(index),
      ),
    );
  });
}

List<Marker> buildPlaceMarkers({
  required List<Place> places,
  required double markerSize,
  required ShowPlaceInfoCallback showPlaceInfo,
  required BuildContext context,
}) {
  return places.map((place) {
    IconData markerIcon;
    Color markerColor;

    switch (place.type) {
      case 'Restaurant':
        markerIcon = Icons.restaurant;
        markerColor = Colors.red;
        break;
      case 'Tourist destination':
        markerIcon = Icons.location_city;
        markerColor = Colors.blue;
        break;
      case 'Hotel':
        markerIcon = Icons.hotel;
        markerColor = Colors.green;
        break;
      case 'Museum':
        markerIcon = Icons.museum;
        markerColor = Colors.purple;
        break;
      default:
        markerIcon = Icons.location_on;
        markerColor = Colors.orangeAccent;
    }

    return Marker(
      point: LatLng(place.latitude, place.longitude),
      width: markerSize,
      height: markerSize,
      child: GestureDetector(
        onTap: () => showPlaceInfo(context, place),
        child: Icon(
          markerIcon,
          color: markerColor,
          size: 30,
        ),
      ),
    );
  }).toList();
}

List<Marker> buildCameraMarkers({
  required List<Camera> cameras,
  required double markerSize,
  required ShowYoutubeDialogCallback showYoutubeDialog,
  required BuildContext context,
}) {
  return cameras.map((camera) {
    return Marker(
      point: LatLng(camera.latitude, camera.longitude),
      width: markerSize,
      height: markerSize,
      child: GestureDetector(
        onTap: () => showYoutubeDialog(context, camera.link),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: camera.status
                    ? const Color.fromARGB(255, 242, 237, 216).withOpacity(0.8)
                    : const Color.fromARGB(255, 129, 108, 112).withOpacity(0.8),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.videocam,
            color: camera.status
                ? const Color.fromARGB(255, 204, 181, 67)
                : const Color(0xFFFF1744),
            size: 26,
          ),
        ),
      ),
    );
  }).toList();
}
