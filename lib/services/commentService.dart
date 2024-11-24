import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutterApp/models/comment.dart';
import 'package:flutterApp/models/paginated_data.dart';
import './apiClient.dart';
import './constants.dart'; // Import file chứa endpoint constants
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<PaginatedData<Comment>> fetchCommentByPlace(
      {required String id, int? page = 1, int? limit = 10}) {
    return fetchComments(
        endpoint: COMMENT_LIST_BY_PLACE, id: id, page: page, limit: limit);
  }

  Future<PaginatedData<Comment>> fetchCommentByAccount(
      {required String id, int? page = 1, int? limit = 10}) {
    return fetchComments(
        endpoint: COMMENT_LIST_BY_ACCOUNT, id: id, page: page, limit: limit);
  }

  Future<Comment> createComment({
    required String placeId,
    required int star,
    String? content,
    List<String>? imagePaths,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      // Kiểm tra và lọc những ảnh hợp lệ
      final validImagePaths = imagePaths?.where((path) {
        final file = File(path);
        return file.existsSync() &&
            ['jpg', 'jpeg', 'png', 'gif']
                .contains(path.split('.').last.toLowerCase());
      }).toList();

      // Chỉ thêm 'files' vào formData nếu có ảnh hợp lệ
      final formData = FormData.fromMap({
        'place_id': placeId,
        'star': star,
        'content': content,
        'files': validImagePaths != null && validImagePaths.isNotEmpty
            ? validImagePaths
                .map((path) => MultipartFile.fromFileSync(path))
                .toList()
            : [],
      });

      // Gửi yêu cầu đến backend
      Response response = await _apiClient.dio.post(
        COMMENT_BASE,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'x-access-token': token,
          },
        ),
      );

      // Kiểm tra phản hồi từ backend
      if (response.statusCode == 201) {
        return Comment.fromJson(response.data['data']);
      } else if (response.statusCode == 400) {
        print('Failed to create comment: ${response.data['errors']}');
        throw Exception('Failed to create comment');
      } else {
        print('Failed to create comment. Status code: ${response.statusCode}');
        throw Exception('Failed to create comment');
      }
    } catch (e, stacktrace) {
      print('Error occurred: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
    }
  }

  Future<Comment> deleteComment({
    required String id,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      // Gửi yêu cầu xóa
      Response response = await _apiClient.dio.delete(
        '$COMMENT_BASE/$id',
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );
      // Kiểm tra phản hồi
      if (response.statusCode == 200) {
        // Ánh xạ dữ liệu trả về thành đối tượng Comment
        return Comment.fromJson(response.data['data']);
      } else if (response.statusCode == 400) {
        print('Failed to create comment: ${response.data['errors']}');
        throw Exception('Failed to create comment');
      } else {
        print('Failed to delete comment. Status code: ${response.statusCode}');
        throw Exception('Failed to delete comment');
      }
    } catch (e, stacktrace) {
      print('Error occurred while deleting comment: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
    }
  }

  Future<Comment> updateComment({
    required String id,
    int? star,
    String? content,
    List<String>? replaceImageIds,
    List<String>? newImagePaths,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final validImagePaths = newImagePaths?.where((path) {
        final file = File(path);
        return file.existsSync() &&
            ['jpg', 'jpeg', 'png', 'gif']
                .contains(path.split('.').last.toLowerCase());
      }).toList();
      // Tạo FormData để gửi dữ liệu
      final formData = FormData.fromMap({
        if (star != null) 'star': star,
        if (content != null) 'content': content,
        if (replaceImageIds != null && replaceImageIds.isNotEmpty)
          'replaceImageId': replaceImageIds,
        if (validImagePaths != null && validImagePaths.isNotEmpty)
          'files': validImagePaths.map((path) => MultipartFile.fromFileSync(path)).toList(),
      });
      // Gửi yêu cầu API
      Response response = await _apiClient.dio.put(
        '$COMMENT_BASE/$id', // Thay đổi đường dẫn này phù hợp với server
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'x-access-token': token,
          },
        ),
      );
      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200) {
        return Comment.fromJson(response.data['data']);
      } else if (response.statusCode == 400) {
        print('Failed to create comment: ${response.data['errors']}');
        throw Exception('Failed to create comment');
      } else {
        throw Exception('Failed to update comment. Status code: ${response.statusCode} ${response.data}');
      }
    } catch (e, stacktrace) {
      print('Error occurred: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
    }
  }


}
