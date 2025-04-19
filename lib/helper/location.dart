import 'package:latlong2/latlong.dart';
import 'dart:math';

double calculateDistance(LatLng from, LatLng to) {
  const double radiusEarth = 6371;
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

bool areLatLngEqual(LatLng a, LatLng b) {
  return a.latitude == b.latitude && a.longitude == b.longitude;
}

bool isSubsetRoute(List<LatLng> routeA, List<LatLng> routeB) {
  if (routeA.length > routeB.length) {
    return false;
  }
  for (LatLng pointA in routeA) {
    for (LatLng pointB in routeB) {
      if (areLatLngEqual(pointA, pointB)) {
        return true;
      }
    }
  }
  return false;
}

void addUniqueRoutes(List<List<LatLng>> existingRoutes, List<List<LatLng>> additionalRoutes) {
  for (List<LatLng> newRoute in additionalRoutes) {
    bool isDuplicate = false;

    for (List<LatLng> existingRoute in existingRoutes) {
      if (isSubsetRoute(newRoute, existingRoute)) {
        isDuplicate = true;
        break;
      }
    }

    if (!isDuplicate) {
      existingRoutes.add(newRoute);
    }
  }
}

double calculateDistances(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371;
  final double dLat = (lat2 - lat1) * (3.141592653589793 / 180.0);
  final double dLon = (lon2 - lon1) * (3.141592653589793 / 180.0);

  final double a = 
      (sin(dLat / 2) * sin(dLat / 2)) +
      cos(lat1 * (3.141592653589793 / 180.0)) *
          cos(lat2 * (3.141592653589793 / 180.0)) *
          (sin(dLon / 2) * sin(dLon / 2));
  
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}