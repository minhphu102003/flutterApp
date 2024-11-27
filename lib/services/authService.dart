import 'package:flutterApp/services/apiClient.dart';
import 'package:flutterApp/models/auth.dart';
import 'package:flutterApp/services/apiRespone.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<ApiResponse<AuthToken?>> login(String email, String password) async {
    try {
      Response response = await _apiClient.dio.post(
        '/auth/signin',
        data: {'email': email, 'password': password},
      );
      
      if (response.statusCode == 200) {
        print(response.data);
        final authToken = AuthToken.fromMap(response.data);
        print("token ${authToken.token}");
        await _apiClient.setToken(authToken.token);
        await _apiClient.saveToken(authToken.token);
        return ApiResponse<AuthToken>(data: authToken, error: null);
      } else {
        return ApiResponse<AuthToken>(
            data: null, error: response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse<AuthToken>(
          data: null, error: 'An error has occurred. Please log in again!');
    }
  }

  Future<ApiResponse<AuthToken?>> signUp(
      String username, String email, String password) async {
    try {
      Response response = await _apiClient.dio.post(
        '/auth/signup',
        data: {'username': username, 'email': email, 'password': password},
      );
      if (response.statusCode == 201) {
        final authValue = AuthToken.fromMap(response.data);
        return ApiResponse<AuthToken>(data: authValue, error: null);
      } else {
        String errorMessage = response.data['errors']?.isNotEmpty
            ? response.data['errors'][0]['msg']
            : 'Registration failed';
        return ApiResponse<AuthToken>(data: null, error: errorMessage);
      }
    } catch (e) {
      return ApiResponse<AuthToken>(
          data: null, error: 'An error occurred. Please register again!.');
    }
  }

  Future<String?> forgotPassword(String email) async {
    try {
      Response response = await _apiClient.dio
          .post('/auth/forgot-password', data: {'email': email});
      if (response.statusCode == 200) {
        return null;
      } else {
        String errorMessage = response.data['message'] != null
            ? response.data['message']
            : 'Send failed';
        return errorMessage;
      }
    } catch (e) {
      print('error ${e}');
      return 'An error occurred. Please action again!.';
    }
  }

  Future<String?> verifyOTP(String email, String otp) async {
    try {
      Response response = await _apiClient.dio
          .post('/auth/verify-otp', data: {'email': email, 'otp': otp});
      if (response.statusCode == 200) {
        return null;
      } else {
        String errorMessage = response.data['message'] != null
            ? response.data['message']
            : 'Send failed';
        return errorMessage;
      }
    } catch (e) {
      return 'An error occurred. Please action again!.';
    }
  }

  Future<String?> resetPassword(String email, String password) async {
    try {
      Response response = await _apiClient.dio.post('/auth/reset-password',
          data: {'email': email, 'newPassword': password});
      if (response.statusCode == 200) {
        return null;
      } else {
        String errorMessage = response.data['errors']?.isNotEmpty
            ? response.data['errors'][0]['msg']
            : 'Send failed';
        return errorMessage;
      }
    } catch (e) {
      return 'An error occurred. Please action again!.';
    }
  }
Future<String> logOut() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  // Kiểm tra token có tồn tại hay không
  if (token == null) {
    return 'You are already logged out!';
  }

  try {
    // Gửi request logout tới API
    Response response = await _apiClient.dio.get(
      '/auth/logout',
      options: Options(
        headers: {'x-access-token': token},
      ),
    );

    // Nếu logout thành công
    if (response.statusCode == 200) {
      // Xóa token khỏi SharedPreferences
      await prefs.remove('token');
      return 'Logout successful!';
    }

    // Nếu có lỗi từ API (nhưng không phải exception)
    return response.data['message'] ?? 'Logout failed, please try again!';
  } catch (e) {
    print('Logout error: $e');
    return 'An unexpected error occurred, please try again!';
  }
}

  
}
