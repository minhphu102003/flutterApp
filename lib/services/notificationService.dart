import 'package:dio/dio.dart';
import '../models/notification.dart';
import '../models/paginated_data.dart'; // Assuming TrafficNotification and PaginatedData are in this file
import './apiClient.dart'; // Assuming ApiClient is imported here
import 'package:shared_preferences/shared_preferences.dart';

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
        (json) => TrafficNotification.fromJson(json), // Map JSON tới TrafficNotification
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