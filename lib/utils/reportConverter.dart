import 'package:flutterApp/helper/location.dart';
import 'package:flutterApp/models/notification.dart';
import 'package:flutterApp/models/report.dart';
import 'package:flutterApp/utils/reportUtils.dart';

TrafficNotification convertReportToNotification(Report report, double currentLatitude, double currentLongitude) {
  String title = getTitleFromType(report.typeReport);
  String content = report.description;
  String status = report.congestionLevel;
  bool isRead = false;
  DateTime timestamp = report.timestamp;
  String distance = calculateDistances(
    report.latitude,
    report.longitude,
    currentLatitude,
    currentLongitude,
  ).toStringAsFixed(2);
  double longitude = report.longitude;
  double latitude = report.latitude;
  String img = report.imgs.isNotEmpty ? report.imgs.first.img : '';

  return TrafficNotification(
    title: title,
    content: content,
    status: status,
    isRead: isRead,
    timestamp: timestamp,
    distance: distance,
    longitude: longitude,
    latitude: latitude,
    img: img,
  );
}
