import 'package:latlong2/latlong.dart';
import 'dart:math';

double calculateDistance(LatLng from, LatLng to) {
  const double radiusEarth = 6371; // Bán kính Trái Đất (km)
  double lat1 = from.latitude;
  double lon1 = from.longitude;
  double lat2 = to.latitude;
  double lon2 = to.longitude;

  double dLat = (lat2 - lat1) * (3.141592653589793 / 180.0);
  double dLon = (lon2 - lon1) * (3.141592653589793 / 180.0);

  double a = 
      (sin(dLat / 2) * sin(dLat / 2)) +
      cos(lat1 * (3.141592653589793 / 180.0)) * 
      cos(lat2 * (3.141592653589793 / 180.0)) *
      (sin(dLon / 2) * sin(dLon / 2));
  
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = radiusEarth * c;
  return distance;
}