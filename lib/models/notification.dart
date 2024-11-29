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
    distance: json['distance'].toString(), // Đảm bảo chuyển thành String nếu cần
    longitude: json['longitude'] is double
        ? json['longitude'] as double
        : double.parse(json['longitude'].toString()), // Xử lý cả trường hợp kiểu double và String
    latitude: json['latitude'] is double
        ? json['latitude'] as double
        : double.parse(json['latitude'].toString()), // Tương tự cho latitude
    img: json['img'] as String,
  );
}
}
