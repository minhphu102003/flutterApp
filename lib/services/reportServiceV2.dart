import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutterApp/models/paginated_data.dart';
import 'package:flutterApp/models/reportV2.dart';
import 'package:flutterApp/services/apiClientV2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './constants.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ReportServiceV2 {
  final ApiClientV2 _apiClient = ApiClientV2.instance;

  Future<String> createVideoReport({
    required File videoFile,
    required String typeReport,
    String? description,
    String congestionLevel = "POSSIBLE_CONGESTION",
    required double longitude,
    required double latitude,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception("Authorization token is missing.");
      }

      if (!videoFile.existsSync()) {
        throw Exception("Video file does not exist.");
      }
      print('File Path: ${videoFile.path}');
    print('File Extension: ${videoFile.path.split('.').last}');
    print('File MIME Type: ${lookupMimeType(videoFile.path) ?? "Unknown"}');

      final formData = FormData();

      if (description != null) {
        formData.fields.add(MapEntry('description', description));
      }

      formData.fields.addAll([
        MapEntry('typeReport', typeReport),
        MapEntry('congestionLevel', congestionLevel),
        MapEntry('longitude', longitude.toString()),
        MapEntry('latitude', latitude.toString()),
      ]);

      formData.files.add(
        MapEntry(
          'video',
          await MultipartFile.fromFile(
            videoFile.path,
            filename: videoFile.path.split('/').last,
            contentType: MediaType('video', 'mp4'),
          ),
        ),
      );

      final response = await _apiClient.dio.post(
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
        return 'Video report created successfully';
      } else {
        final data = response.data as Map<String, dynamic>;
        return data['message'] ?? 'Failed to create video report';
      }
    } catch (e) {
      return 'Error occurred: $e';
    }
  }

Future<PaginatedData<AccountReportV2>> getReports({
  int page = 1,
  int limit = 10,
  String? startDate,
  String? endDate,
  String? typeReport,
  String? congestionLevel,
  String? accountId,
  bool? analysisStatus,
}) async {
  try {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (typeReport != null) 'typeReport': typeReport,
      if (congestionLevel != null) 'congestionLevel': congestionLevel,
      if (accountId != null) 'account_id': accountId,
      if (analysisStatus != null) 'analysisStatus': analysisStatus.toString(),
    };

    final response = await _apiClient.dio.get(
      REPORT_ENDPOINT,
      queryParameters: queryParams,
    );


    if (response.statusCode == 200 && response.data['success'] == true) {
      return PaginatedData<AccountReportV2>.fromJson(
        response.data,
        (json) => AccountReportV2.fromJson(json),
      );
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch reports');
    }
  } catch (e) {
    print('🔥 Exception in getReports: $e');
    rethrow;
  }
}
}
