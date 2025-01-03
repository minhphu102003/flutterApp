class RestResponse {
  final bool success;
  final int total;
  final int count;
  final int totalPages;
  final int currentPage;

  RestResponse({
    required this.success,
    required this.total,
    required this.count,
    required this.totalPages,
    required this.currentPage,
  });

  factory RestResponse.fromJson(Map<String, dynamic> json) {
    return RestResponse(
      success: json['success'],
      total: json['total'],
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
    );
  }
}