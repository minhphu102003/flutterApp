class Camera {
  final String id;
  final String link;
  final bool status;
  final DateTime installationDate;
  final List<String> roadSegments;
  final DateTime updatedAt;
  final double latitude;
  final double longitude;

  Camera({
    required this.id,
    required this.link,
    required this.status,
    required this.installationDate,
    required this.roadSegments,
    required this.updatedAt,
    required this.latitude,
    required this.longitude,
  });

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['_id'],
      link: json['link'],
      status: json['status'],
      installationDate: DateTime.parse(json['installation_date']),
      roadSegments: List<String>.from(json['roadSegments']),
      updatedAt: DateTime.parse(json['updatedAt']),
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
