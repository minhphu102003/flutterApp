import 'restful_response.dart';

class PaginatedData<T> extends RestResponse {
  final List<T> data;

  PaginatedData({
    required super.success,
    required super.total,
    required super.count,
    required super.totalPages,
    required super.currentPage,
    required this.data,
  });

  factory PaginatedData.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    var dataList =
        (json['data'] as List).map((item) => fromJsonT(item)).toList();
    return PaginatedData(
      success: json['success'] ?? false,
      total: json['total'] ?? 0,
      count: json['count'] ?? dataList.length,
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['currentPage'] ?? 1,
      data: dataList,
    );
  }
}
