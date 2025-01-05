import 'package:flutterApp/services/apiClient.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './constants.dart';

class AccountService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> getProfile() async {
    try {
      // Lấy token từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token not found');
      }
      Response response = await _apiClient.dio.get(
        ACCOUNT_PROIFLE,
        options: Options(
          headers: {'x-access-token': token},
        ),
      );  
      if (response.statusCode == 200 && response.data['success']) {
        return response.data;
      } else {
        throw Exception('Failed to fetch profile');
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching profile',
        'error': e.toString(),
      };
    }
  }
}
