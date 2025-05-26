import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutterApp/models/report.dart';
import 'package:flutterApp/models/paginated_data.dart';
import './constants.dart';
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
    bool analysisStatus = true,
    bool guest = true,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (typeReport != null) queryParams['typeReport'] = typeReport;
      if (congestionLevel != null) {
        queryParams['congestionLevel'] = congestionLevel;
      }
      if (accountId != null) queryParams['account_id'] = accountId;

      queryParams['analysisStatus'] = analysisStatus.toString();
      queryParams['guest'] = guest.toString();

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      Response response = await _apiClient.dio.get(
        REPORT_ENDPOINT,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data as Map<String, dynamic>;
        return PaginatedData<Report>.fromJson(
          jsonResponse,
          (json) => Report.fromJson(json),
        );
      } else {
        throw Exception('Failed to load account reports');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createAccountReport({
    required String description,
    required String typeReport,
    String congestionLevel = "POSSIBLE_CONGESTION",
    required double longitude,
    required double latitude,
    required List<File>? imageFiles,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception("Authorization token is missing.");
      }

      final validImageFiles = imageFiles?.where((file) {
        return file.existsSync() &&
            ['jpg', 'jpeg', 'png', 'gif']
                .contains(file.path.split('.').last.toLowerCase());
      }).toList();

      final formData = FormData.fromMap({
        'description': description,
        'typeReport': typeReport,
        'congestionLevel': congestionLevel,
        'longitude': longitude.toString(),
        'latitude': latitude.toString(),
        if (validImageFiles != null && validImageFiles.isNotEmpty)
          'files': await Future.wait(
            validImageFiles.map(
              (file) => MultipartFile.fromFile(file.path,
                  filename: file.path.split('/').last),
            ),
          ),
      });

      Response response = await _apiClient.dio.post(
        REPORT_ENDPOINT,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 201) {
        return 'Report created successfully';
      } else {
        final jsonResponse = response.data as Map<String, dynamic>;
        return jsonResponse['message'] ?? 'Failed to create account report';
      }
    } catch (e) {
      return 'Error occurred: $e';
    }
  }
}
