import 'dart:math';

double calculateRadius(double zoom, {double baseZoom = 16.0, double baseRadius = 300}) {
  return baseRadius * pow(2, baseZoom - zoom);
}