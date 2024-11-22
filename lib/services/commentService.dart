import 'package:dio/dio.dart';
import 'package:flutterApp/models/comment.dart';
import 'package:flutterApp/models/paginated_data.dart';
import './apiClient.dart';
import './constants.dart'; // Import file chứa endpoint constants

class CommentService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<PaginatedData<Comment>> fetchComments({
    required String endpoint,
    required String id,
    int? page = 1,
    int? limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        "page": page ?? 1,
        "limit": limit ?? 10,
      };

      Response response = await _apiClient.dio.get(
        '$endpoint/$id',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data as Map<String, dynamic>;
        return PaginatedData<Comment>.fromJson(
          jsonResponse,
          (json) => Comment.fromJson(json as Map<String, dynamic>),
        );
      } else {
        print('Failed request. Status code: ${response.statusCode}');
        print('Response body: ${response.data}');
        throw Exception('Failed to fetch comments from $endpoint');
      }
    } catch (e, stacktrace) {
      print('Error occurred in $endpoint: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
    }
  }

  Future<PaginatedData<Comment>> fetchCommentByPlace({required String id, int? page = 1, int? limit = 10}) {
    return fetchComments(endpoint: COMMENT_LIST_BY_PLACE, id: id, page: page, limit: limit);
  }

  Future<PaginatedData<Comment>> fetchCommentByAccount({required String id, int? page = 1, int? limit = 10}) {
    return fetchComments(endpoint: COMMENT_LIST_BY_ACCOUNT, id: id, page: page, limit: limit);
  }
}
