import 'package:dio/dio.dart';
import './apiClient.dart';
import 'package:flutterApp/models/paginated_data.dart';
import 'package:flutterApp/models/camera.dart'; // Bạn cần tạo model Camera
import './constants.dart';

class CameraService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<PaginatedData<Camera>> fetchNearbyCameras({
    required double latitude,
    required double longitude,
    int page = 1,
    int limit = 10,
    int distance = 10,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
        'distance': distance.toString(),
      };

      final response = await _apiClient.dio.get(
        CAMERA_ENDPOINT,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data as Map<String, dynamic>;

        return PaginatedData<Camera>.fromJson(
          jsonResponse,
          (json) => Camera.fromJson(json),
        );
      } else {
        throw Exception('Failed to load camera data');
      }
    } catch (e) {
      throw Exception('Error fetching camera data: $e');
    }
  }
}
