class Place {
  final String id;
  final String type;
  final String name;
  final double star;
  final String img;
  final bool status;
  final String? timeOpen;
  final String? timeClose;
  final double longitude;
  final double latitude;

  Place({
    required this.id,
    required this.type,
    required this.name,
    required this.star,
    required this.img,
    required this.status,
    this.timeOpen,
    this.timeClose,
    required this.longitude,
    required this.latitude,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      star: json['star']?.toDouble(),
      img: json['img'],
      status: json['status'],
      timeOpen: json['timeOpen'],
      timeClose: json['timeClose'],
      longitude: json['longitude'].toDouble(),
      latitude: json['latitude'].toDouble(),
    );
  }
}