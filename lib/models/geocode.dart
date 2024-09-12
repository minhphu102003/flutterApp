import 'package:latlong2/latlong.dart';

class GeocodeData {
  String name;
  LatLng latLng;

  GeocodeData({
    required this.name,
    required this.latLng
  });

  factory GeocodeData.fromJson(Map<String, dynamic> json){
    return GeocodeData(
      name: json['name'], latLng: LatLng(json['lat'], json['lon'])
    );
  }
}