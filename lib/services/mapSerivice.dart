import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';
import 'package:flutterApp/config.dart';
import 'package:flutterApp/helper/appConfig.dart';
import 'package:dio/dio.dart';
import './apiClient.dart';

class MapApiService {
  static const String apiMapboxKey = Config.api_mapbox_key;
  static const String baseMapBoxGeo = AppConfig.baseMapBoxGeo;
  static const String baseMapBoxDir = AppConfig.baseMapBoxDir;
  static const String apiKeyGongMap = Config.api_gongmap_key;
  static const String baseUrlGoongMap = AppConfig.baseUrlGoongMap;
  static const String _baseUrl = AppConfig.baseUrlOpenStreet;
  final ApiClient _apiClient = ApiClient.instance;

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
      return data['features']
          .map<String>((item) => item['place_name'].toString())
          .toList();
    }
    return [];
  }

  static Future<List<LatLng>> getRoute(LatLng start, LatLng destination) async {
    final url =
        '$baseMapBoxDir/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&steps=true&access_token=$apiMapboxKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        print(data['routes'][0]['geometry']['coordinates']);
        final route = data['routes'][0]['geometry']['coordinates'] as List;
        return route.map((point) => LatLng(point[1], point[0])).toList();
      }
    }
    return [];
  }

  static Future<List<String>> getRouteInstructions(
      LatLng start, LatLng destination) async {
    final url =
        '$baseMapBoxDir/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&steps=true&access_token=$apiMapboxKey';
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

  static Future<String> getTravelTime(LatLng start, LatLng destination) async {
    final url =
        '$baseMapBoxDir/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&steps=true&access_token=$apiMapboxKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        if (route['duration'] != null) {
          final duration =
              (route['duration'] as num) / 60; // Chuyển đổi từ giây sang phút
          return '${duration.toStringAsFixed(0)} phút'; // Trả về thời gian di chuyển
        } else {
          return 'Không xác định';
        }
      }
    }
    return 'Không xác định'; // Trường hợp không có dữ liệu hoặc lỗi
  }

  static Future<List<Map<String, String>>> getSuggestionsVerGoongMap(
      String query, double latitude, double longitude) async {
    final location = '$latitude,$longitude';
    final url =
        '$baseUrlGoongMap/AutoComplete?api_key=$apiKeyGongMap&location=$location&input=$query';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;

        return predictions.map<Map<String, String>>((item) {
          return {
            'description': item['description'],
            'place_id': item['place_id'],
          };
        }).toList();
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return [];
  }

  static Future<LatLng?> getPlaceCoordinates(String placeId) async {
    final url =
        '$baseUrlGoongMap/Detail?place_id=$placeId&api_key=$apiKeyGongMap';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] != null && data['result']['geometry'] != null) {
          final location = data['result']['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      } else {
        print('Failed to fetch details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> getRoutes(LatLng start, LatLng destination,
      {String vehicleType = 'drive'}) async {
    try {
      // Tạo URL từ cấu hình `ApiClient`
      final response = await _apiClient.dio.get(
        '/routes',
        queryParameters: {
          'start': '${start.longitude},${start.latitude}',
          'end': '${destination.longitude},${destination.latitude}',
          'vehicleType': vehicleType,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null) {
          List<List<LatLng>> allRoutes = [];
          List<List<LatLng>> allIntersections = [];
          for (var route in data['routes']) {
            List<LatLng> routeCoordinates = [];
            String encodedPolyline = route['geometry'];
            final decodedPoints =
                PolylinePoints().decodePolyline(encodedPolyline);
            routeCoordinates.addAll(
              decodedPoints
                  .map((point) => LatLng(point.latitude, point.longitude)),
            );
            List<LatLng> intersections = [];
            for (var leg in route['legs']) {
              for (var step in leg['steps']) {
                for (var intersection in step['intersections']) {
                  intersections.add(
                    LatLng(intersection['location'][1],
                        intersection['location'][0]),
                  );
                }
              }
            }
            allRoutes.add(routeCoordinates);
            allIntersections.add(intersections);
          }
          return {
            'routes': allRoutes,
            'intersections': allIntersections,
          };
        } else {
          throw Exception("No routes found");
        }
      } else {
        throw Exception("Failed to fetch routes: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching routes: $error");
      throw error;
    }
  }

  static Future<Map<String, dynamic>> getRoutesVerWayPoints(
      LatLng start, LatLng destination) async {
    final url =
        '$_baseUrl/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?alternatives=true&steps=true';
    try {
      // Gọi API
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 'Ok') {
          List<List<LatLng>> allRoutes = [];
          List<LatLng> allWaypoints = [];

          // Xử lý danh sách các tuyến đường
          for (var route in data['routes']) {
            String encodedPolyline = route['geometry'];
            List<PointLatLng> decodedPoints =
                PolylinePoints().decodePolyline(encodedPolyline);

            // Chuyển đổi từ PointLatLng sang LatLng
            List<LatLng> latLngList = decodedPoints
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();

            allRoutes.add(latLngList);
          }

          // Xử lý danh sách waypoints
          for (var waypoint in data['waypoints']) {
            // Lấy thông tin location từ waypoint và chuyển thành LatLng
            List<dynamic> location = waypoint['location'];
            if (location.length == 2) {
              LatLng latLngWaypoint = LatLng(location[1], location[0]);
              allWaypoints.add(latLngWaypoint);
            }
          }

          // Trả về kết quả
          return {
            'routes': allRoutes, // Danh sách các tuyến đường
            'waypoints': allWaypoints, // Danh sách các giao điểm (waypoints)
          };
        } else {
          throw Exception("API Error: ${data['code']}");
        }
      } else {
        throw Exception("Failed to fetch routes: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  Future<List<String>> getInstruction(LatLng start, LatLng destination,
      {String vehicleType = 'drive'}) async {
    try {
      // Tạo URL từ cấu hình ApiClient
      final response = await _apiClient.dio.get(
        '/routes',
        queryParameters: {
          'start': '${start.longitude},${start.latitude}',
          'end': '${destination.longitude},${destination.latitude}',
          'vehicleType': vehicleType,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final legs = routes[0]['legs'] as List;
          if (legs.isNotEmpty) {
            final steps = legs[0]['steps'] as List;
            final instructions = steps.map<String>((step) {
              String name = step['name'] as String;
              // Loại bỏ phần trước khoảng cách đầu tiên
              if (name.contains(' ')) {
                name = name.substring(name.indexOf(' ') + 1).trim();
              }
              final distance = (step['distance'] as num).toDouble();
              return 'Passing $name (${distance.toStringAsFixed(1)} m)';
            }).toList();
            return instructions;
          }
        }
      }
      return [];
    } catch (e) {
      // In ra lỗi để debug
      print('Lỗi khi lấy routes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getRoutesWithInstructions(
      LatLng start, LatLng destination,
      {String vehicleType = 'drive'}) async {
    try {
      final response = await _apiClient.dio.get(
        '/routes',
        queryParameters: {
          'start': '${start.longitude},${start.latitude}',
          'end': '${destination.longitude},${destination.latitude}',
          'vehicleType': vehicleType,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['routes'] != null) {
          List<Map<String, dynamic>> routesWithInstructions = [];

          for (var route in data['routes']) {
            List<LatLng> routeCoordinates = [];
            String encodedPolyline = route['geometry'];
            final decodedPoints =
                PolylinePoints().decodePolyline(encodedPolyline);
            routeCoordinates.addAll(
              decodedPoints
                  .map((point) => LatLng(point.latitude, point.longitude)),
            );

            List<LatLng> intersections = [];
            List<String> instructions = [];

            for (var leg in route['legs']) {
              for (var step in leg['steps']) {
                for (var intersection in step['intersections']) {
                  intersections.add(
                    LatLng(intersection['location'][1],
                        intersection['location'][0]),
                  );
                }

                String name = step['name'] as String;
                if (name.contains(' ')) {
                  name = name.substring(name.indexOf(' ') + 1).trim();
                }

                final distance = (step['distance'] as num).toDouble();

                if (distance != 0) {
                  instructions
                      .add('Passing $name (${distance.toStringAsFixed(1)} m)');
                }
              }
            }

            final bool recommended = route['recommended'] ?? false;

            List<Map<String, dynamic>> report = [];
            if (!recommended && route['report'] != null) {
              final reportList = route['report'] as List<dynamic>;
              report = reportList.map((rep) {
                if (rep is Map<String, dynamic>) {
                  return {
                    'trafficVolume': rep['trafficVolume'],
                    'congestionLevel': rep['congestionLevel'],
                    'typeReport': rep['typeReport'],
                    'img': rep['img'],
                    'timestamp': rep['timestamp'],
                    'latitude': rep['latitude'],
                    'longitude': rep['longitude'],
                  };
                } else {
                  throw Exception("Invalid report format");
                }
              }).toList();
            }

            routesWithInstructions.add({
              'coordinates': routeCoordinates,
              'instructions': instructions,
              'intersections': intersections,
              'recommended': recommended,
              'report': report,
            });
          }
          return {'routesWithInstructions': routesWithInstructions};
        } else {
          throw Exception("No routes found");
        }
      } else {
        throw Exception("Failed to fetch routes: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching routes and instructions: $error");
      throw error;
    }
  }
}
