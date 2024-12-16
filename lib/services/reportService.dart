import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutterApp/models/report.dart';
import 'package:flutterApp/models/paginated_data.dart';
import './apiClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<PaginatedData<Report>> fetchAccountReport({
    int? page,
    int? limit,
    String? typeReport,
    int? congestionLevel,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
    bool? analysisStatus,
  }) async {
    try {
      // Tạo danh sách queryParams động
      final Map<String, dynamic> queryParams = {};

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (typeReport != null) queryParams['typeReport'] = typeReport;
      if (congestionLevel != null)
        queryParams['congestionLevel'] = congestionLevel;
      if (accountId != null) queryParams['account_id'] = accountId;
      if (analysisStatus != null)
        queryParams['analysisStatus'] = analysisStatus.toString();

      // Chuyển đổi DateTime sang chuỗi ISO8601 cho `startDate` và `endDate`
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      // Gửi request tới API
      Response response = await _apiClient.dio.get(
        '/account-report',
        queryParameters: queryParams,
      );

      // Kiểm tra trạng thái phản hồi
      if (response.statusCode == 201) {
        final jsonResponse = response.data as Map<String, dynamic>;
        return PaginatedData<Report>.fromJson(
          jsonResponse,
          (json) => Report.fromJson(json as Map<String, dynamic>),
        );
      } else {
        throw Exception('Failed to load account reports');
      }
    } catch (e) {
      print('Error occurred: $e');
      rethrow;
    }
  }
  
// Chuyển từ _images sang đường dẫn ảnh trong createAccountReport
Future<String> createAccountReport({
  required String description,
  required String typeReport,
  String congestionLevel = "POSSIBLE_CONGESTION",
  required double longitude,
  required double latitude,
  required List<File>? imageFiles, // Sử dụng List<File> thay vì List<String>?
}) async {
  try {
    // Lấy token từ SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception("Authorization token is missing.");
    }

    // Kiểm tra và lọc những file ảnh hợp lệ
    final validImageFiles = imageFiles?.where((file) {
      return file.existsSync() &&
          ['jpg', 'jpeg', 'png', 'gif']
              .contains(file.path.split('.').last.toLowerCase());
    }).toList();

    // Tạo FormData để gửi thông tin báo cáo kèm ảnh
    final formData = FormData.fromMap({
      'description': description,
      'typeReport': typeReport,
      'congestionLevel': congestionLevel,
      'longitude': longitude.toString(),
      'latitude': latitude.toString(),
      if (validImageFiles != null && validImageFiles.isNotEmpty)
        'files': await Future.wait(
          validImageFiles.map(
            (file) => MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
          ),
        ),
    });

    // Gửi request POST tới API
    Response response = await _apiClient.dio.post(
      '/account-report', // Đường dẫn API
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'x-access-token': token, // Thay bằng token thực tế
        },
      ),
    );

    // Kiểm tra phản hồi
    if (response.statusCode == 201) {
      return 'Report created successfully'; // Trả về thông báo thành công
    } else {
      // Trả về thông báo thất bại khi không phải mã 201
      print(response);
      final jsonResponse = response.data as Map<String, dynamic>;
      return jsonResponse['message'] ?? 'Failed to create account report'; // Trả về message nếu có, nếu không trả về thông báo mặc định
    }
  } catch (e) {
    print('Error occurred: $e');
    return 'Error occurred: $e'; // Trả về thông báo lỗi nếu có lỗi trong quá trình xử lý
  }
}

}
