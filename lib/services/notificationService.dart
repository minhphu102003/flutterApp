import 'package:dio/dio.dart';
import 'package:flutterApp/services/constants.dart';
import '../models/notification.dart';
import '../models/paginated_data.dart';
import './apiClient.dart';
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found. Please log in again.');
      }
      _apiClient.dio.options.headers['x-access-token'] = token;
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final double userLongitude = position.longitude;
      final double userLatitude = position.latitude;
      final Response response = await _apiClient.dio.get(
        NOTIFICATION_ENDPOINT,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      if (response.statusCode == 200) {
        final paginatedData = PaginatedData<TrafficNotification>.fromJson(
          response.data,
          (json) {
            final notification = TrafficNotification.fromJson(json);

            notification.distance = '${calculateDistances(
              userLatitude,
              userLongitude,
              notification.latitude,
              notification.longitude,
            ).toStringAsFixed(2)} km';
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

  Future<TrafficNotification?> updateNotificationStatus(String notificationId) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found. Please log in again.');
    }

    final Response response = await _apiClient.dio.put(
      '$NOTIFICATION_ENDPOINT/$notificationId',
      data: {
        'status': 'READ',
      },
      options: Options(
        headers: {
          'x-access-token': token,
        },
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return TrafficNotification.fromJson(response.data['data']);
    } else {
      print('Failed to update notification: ${response.data}');
      return null;
    }
  } catch (e) {
    print('Error updating notification: $e');
    return null;
  }
}
}
