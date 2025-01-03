import 'package:dio/dio.dart';
import '../models/notification.dart';
import '../models/paginated_data.dart'; // Assuming TrafficNotification and PaginatedData are in this file
import './apiClient.dart'; // Assuming ApiClient is imported here
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutterApp/helper/location.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient.instance;

Future<PaginatedData<TrafficNotification>> getNotifications({
  int page = 1,
  int limit = 10,
}) async {
  try {
    // Lấy token từ SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found. Please log in again.');
    }
    final String endpoint = '/notification';
    // Đặt token vào headers
    _apiClient.dio.options.headers['x-access-token'] = token;
          // Lấy vị trí hiện tại của người dùng
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final double userLongitude = position.longitude;
      final double userLatitude = position.latitude;
    // Gửi yêu cầu GET để lấy danh sách thông báo
    final Response response = await _apiClient.dio.get(
      endpoint,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    // Kiểm tra phản hồi thành công
    if (response.statusCode == 200) {
      // Chuyển đổi JSON phản hồi thành PaginatedData
              final paginatedData = PaginatedData<TrafficNotification>.fromJson(
          response.data,
          (json) {
            final notification = TrafficNotification.fromJson(json);

            // Tính toán khoảng cách từ vị trí người dùng đến vị trí thông báo
            notification.distance = calculateDistances(
              userLatitude,
              userLongitude,
              notification.latitude,
              notification.longitude,
            ).toStringAsFixed(2) + ' km'; // Giữ 2 chữ số thập phân
            return notification;
          },
        );
      return paginatedData;
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error fetching notifications: $error');
  }
}
}