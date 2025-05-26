class MediaFile {
  final String url;
  final String type;

  MediaFile({
    required this.url,
    required this.type,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      url: json['url'],
      type: json['type'],
    );
  }

  String toDebugString() {
    return 'Type: $type | URL: $url';
  }
}

class AccountReportV2 {
  final String reportId;
  final String? description;
  final String typeReport;
  final String congestionLevel;
  final bool analysisStatus;
  final double longitude;
  final double latitude;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String accountId;
  final String username;
  final List<String> roles;
  final MediaFile? mediaFile;

  AccountReportV2({
    required this.reportId,
    this.description,
    required this.typeReport,
    required this.congestionLevel,
    required this.analysisStatus,
    required this.longitude,
    required this.latitude,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
    required this.accountId,
    required this.username,
    required this.roles,
    required this.mediaFile,
  });

  factory AccountReportV2.fromJson(Map<String, dynamic> json) {
    return AccountReportV2(
      reportId: json['reportId'],
      description: json['description'],
      typeReport: json['typeReport'],
      congestionLevel: json['congestionLevel'],
      analysisStatus: json['analysisStatus'],
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      accountId: json['accountId'],
      username: json['username'],
      roles: List<String>.from(json['roles']),
      mediaFile: json['mediaFiles'] != null
          ? MediaFile.fromJson(json['mediaFiles'])
          : null,
    );
  }

  String toDebugString() {
    return '''
📝 Report ID: $reportId
📄 Description: ${description ?? 'N/A'}
📍 Location: ($latitude, $longitude)
📦 Type: $typeReport | Congestion: $congestionLevel | Analyzed: $analysisStatus
👤 User: $username ($accountId) | Roles: ${roles.join(', ')}
🕒 Timestamp: $timestamp | Created: $createdAt | Updated: $updatedAt
🎥 Media: ${mediaFile?.toDebugString() ?? 'No media'}
''';
  }
}
