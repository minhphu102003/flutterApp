import 'package:dio/dio.dart';
import 'package:flutterApp/services/constants.dart';
import 'package:flutterApp/services/apiClientV2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportReviewService {
  final ApiClientV2 _apiClient = ApiClientV2.instance;

  Future<String> createAccountReportReview({
    required String accountReportId,
    required String reason,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception("Authorization token is missing.");
      }

      final response = await _apiClient.dio.post(
        REPORT_REVIEW_ENDPOINT,
        data: {
          'accountReport_id': accountReportId,
          'reason': reason,
        },
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 201) {
        return 'Report review created successfully';
      } else {
        final jsonResponse = response.data as Map<String, dynamic>;
        return jsonResponse['message'] ??
            'Failed to create account report';
      }
    } on DioException catch (e) {
      return 'Error occurred: $e';
    }
  }
}
