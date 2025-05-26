class PredictionData {
  final RoadSegment roadSegment;
  final DateTime timestamp;

  PredictionData({
    required this.roadSegment,
    required this.timestamp,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      roadSegment: RoadSegment.fromJson(json['roadSegment']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class RoadSegment {
  final String id;
  final LineString roadSegmentLine;
  final GeoPoint startLocation;
  final GeoPoint endLocation;
  final double nearRiver;
  final double groundwaterLevel;
  final String? roadName;

  RoadSegment({
    required this.id,
    required this.roadSegmentLine,
    required this.startLocation,
    required this.endLocation,
    required this.nearRiver,
    required this.groundwaterLevel,
    this.roadName,
  });

  factory RoadSegment.fromJson(Map<String, dynamic> json) {
    return RoadSegment(
      id: json['_id'],
      roadSegmentLine: LineString.fromJson(json['roadSegmentLine']),
      startLocation: GeoPoint.fromJson(json['start_location']),
      endLocation: GeoPoint.fromJson(json['end_location']),
      nearRiver: (json['near_river'] as num).toDouble(),
      groundwaterLevel: (json['groundwater_level'] as num).toDouble(),
      roadName: json['roadName'] as String?,
    );
  }
}

class LineString {
  final String type;
  final List<List<double>> coordinates;

  LineString({
    required this.type,
    required this.coordinates,
  });

  factory LineString.fromJson(Map<String, dynamic> json) {
    return LineString(
      type: json['type'],
      coordinates: List<List<double>>.from(
          json['coordinates'].map((c) => List<double>.from(c))),
    );
  }
}

class GeoPoint {
  final String type;
  final List<double> coordinates;

  GeoPoint({
    required this.type,
    required this.coordinates,
  });

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates']),
    );
  }
}
