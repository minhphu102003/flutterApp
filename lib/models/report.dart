class Report {
  final String reportId;
  final String description;
  final String typeReport;
  final String congestionLevel;
  final bool analysisStatus;
  final double longitude;
  final double latitude;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ReportImage> imgs;
  final String accountId;
  final String username;
  final List<String> roles;

  Report({
    required this.reportId,
    required this.description,
    required this.typeReport,
    required this.congestionLevel,
    required this.analysisStatus,
    required this.longitude,
    required this.latitude,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
    required this.imgs,
    required this.accountId,
    required this.username,
    required this.roles,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['reportId'],
      description: json['description'],
      typeReport: json['typeReport'],
      congestionLevel: json['congestionLevel'],
      analysisStatus: json['analysisStatus'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      timestamp: DateTime.parse(json['timestamp']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      imgs: (json['imgs'] as List)
          .map((imgJson) => ReportImage.fromJson(imgJson))
          .toList(),
      accountId: json['accountId'],
      username: json['username'],
      roles: List<String>.from(json['roles']),
    );
  }
}

class ReportImage {
  final String img;
  final String id;

  ReportImage({
    required this.img,
    required this.id,
  });

  factory ReportImage.fromJson(Map<String, dynamic> json) {
    return ReportImage(
      img: json['img'],
      id: json['_id'],
    );
  }
}
