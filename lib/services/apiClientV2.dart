import 'package:dio/dio.dart';
import 'package:flutterApp/helper/appConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiClientV2 {
  late final Dio _dio;

  static final ApiClientV2 instance = ApiClientV2._internal();

  ApiClientV2._internal() {
    String baseUrl = kIsWeb ? AppConfig.baseUrlWebV2 : AppConfig.baseUrlV2;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        responseType: ResponseType.json,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        validateStatus: (int? code) => true,
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> setToken(String token) async {
    _dio.options.headers['x-access-token'] = token;
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      _dio.options.headers['x-access-token'] = token;
    }
  }
}