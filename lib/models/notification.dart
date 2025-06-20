import 'package:uuid/uuid.dart';

var uuid = Uuid();

class TrafficNotification {
  final String id;
  final String title;
  final String content;
  final String status;
  final bool isRead;
  final DateTime timestamp;
  String distance;
  final double longitude;
  final double latitude;
  final String img;

  TrafficNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.isRead,
    required this.timestamp,
    required this.distance,
    required this.longitude,
    required this.latitude,
    required this.img,
  });

  factory TrafficNotification.fromJson(Map<String, dynamic> json) {
    return TrafficNotification(
      id: (json['_id'] ?? uuid.v4()) as String,
      title: json['title'] as String,
      content: json['content'] as String,
      status: json['status'] as String,
      isRead: json['isRead'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      distance: json['distance'].toString(),
      longitude: json['longitude'] is double
          ? json['longitude'] as double
          : double.parse(json['longitude'].toString()),
      latitude: json['latitude'] is double
          ? json['latitude'] as double
          : double.parse(json['latitude'].toString()),
      img: json['img'] as String,
    );
  }
}
