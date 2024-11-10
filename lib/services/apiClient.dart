import 'package:dio/dio.dart';
import 'package:flutterApp/helper/appConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      responseType: ResponseType.json,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      validateStatus: (int? code) {
        return true;
      },
    ),
  );

  static final ApiClient instance = ApiClient._internal();

  ApiClient._internal();

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
