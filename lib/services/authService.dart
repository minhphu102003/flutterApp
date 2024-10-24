import 'package:dio/dio.dart';
import 'package:flutterApp/helper/appConfig.dart';
import 'package:flutterApp/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      responseType: ResponseType.json,
      connectTimeout: Duration(seconds: 10), // Tăng thời gian timeout
      receiveTimeout: Duration(seconds: 10), // Tăng thời gian nhận timeout
      validateStatus: (int? code) {
        return true;
      },
    ),
  );

  static Future<String?> login({
    required String username,
    required String password,
  }) async {
    try {
      Response response = await _dio.post(
        '/auth/signin',
        data: <String, String>{
          'email': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final authToken = AuthToken.fromJson(json.encode(response.data));
        await saveToken(authToken.token);
        setToken(authToken.token);
        return null; // Không có lỗi
      } else {
        // Trả về thông báo lỗi từ server
        return response.data['message'] ?? 'Đăng nhập không thành công';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Có lỗi xảy ra, vui lòng thử lại.';
    }
  }

  static void setToken(String token) {
    _dio.options.headers['x-access-token'] = token;
  }

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
}
