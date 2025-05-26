import 'package:flutterApp/models/account.dart';
import 'package:flutterApp/services/apiClient.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './constants.dart';

class AccountService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<Map<String, dynamic>> getProfile() async {
    try {
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

  Future<AccountModel?> updateProfile({
    required String username,
    required String email,
    required String phone,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw Exception('Token not found');
      }

      Response response = await _apiClient.dio.put(
        ACCOUNT_PROIFLE,
        data: {
          'username': username,
          'email': email,
          'phone': phone,
        },
        options: Options(
          headers: {'x-access-token': token},
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final accountJson = response.data['data'];
        return AccountModel.fromJson(accountJson);
      }
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }
}
