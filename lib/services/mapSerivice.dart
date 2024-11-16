import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterApp/config.dart';
import 'package:flutterApp/helper/appConfig.dart';

class MapApiService {
  static final String apiMapboxKey = Config.api_mapbox_key;
  static final String baseMapBoxGeo = AppConfig.baseMapBoxGeo;
  static final String baseMapBoxDir = AppConfig.baseMapBoxDir;

  static Future<LatLng?> searchLocation(String query) async {
    final url = '$baseMapBoxGeo/$query.json?access_token=$apiMapboxKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'].isNotEmpty) {
        final coordinates = data['features'][0]['geometry']['coordinates'];
        return LatLng(coordinates[1], coordinates[0]);
      }
    }
    return null;
  }

  static Future<List<String>> getSuggestions(String query) async {
    final url = '$baseMapBoxGeo/$query.json?access_token=$apiMapboxKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['features'].map<String>((item) => item['place_name'].toString()).toList();
    }
    return [];
  }

  static Future<List<LatLng>> getRoute(LatLng start, LatLng destination) async {
    final url = '$baseMapBoxDir/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&steps=true&access_token=$apiMapboxKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final route = data['routes'][0]['geometry']['coordinates'] as List;
        return route.map((point) => LatLng(point[1], point[0])).toList();
      }
    }
    return [];
  }

  
  static Future<List<String>> getRouteInstructions(LatLng start, LatLng destination) async {
    final url = '$baseMapBoxDir/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&steps=true&access_token=$apiMapboxKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final legs = data['routes'][0]['legs'] as List;
        List<String> instructions = [];
        for (var leg in legs) {
          final steps = leg['steps'] as List;
          for (var step in steps) {
            instructions.add(step['maneuver']['instruction'].toString());
          }
        }
        return instructions;
      }
    }
    return [];
  }

    // Phương thức để lấy thời gian di chuyển (travelTime)
  static Future<String> getTravelTime(LatLng start, LatLng destination) async {
    final url = '$baseMapBoxDir/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&steps=true&access_token=$apiMapboxKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        if (route['duration'] != null) {
          final duration = (route['duration'] as num) / 60;  // Chuyển đổi từ giây sang phút
          return '${duration.toStringAsFixed(0)} phút'; // Trả về thời gian di chuyển
        } else {
          return 'Không xác định';
        }
      }
    }
    return 'Không xác định'; // Trường hợp không có dữ liệu hoặc lỗi
  }
}
