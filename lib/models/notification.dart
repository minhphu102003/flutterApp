class TrafficNotification {
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
      title: json['title'] as String,
      content: json['content'] as String,
      status: json['status'] as String,
      isRead: json['isRead'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      distance: json['distance'] as String,
      longitude: double.parse(json['longitude'] as String),
      latitude: double.parse(json['latitude'] as String),
      img: json['img'] as String,
    );
  }
}
