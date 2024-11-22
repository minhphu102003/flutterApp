import 'package:dio/dio.dart';
import 'package:flutterApp/models/report.dart';
import 'package:flutterApp/models/paginated_data.dart';
import './apiClient.dart';

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
      if (response.statusCode == 200) {
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
}
