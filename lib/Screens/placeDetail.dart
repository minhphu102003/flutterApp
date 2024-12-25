import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutterApp/models/place.dart' as place_model;
import 'package:flutterApp/services/commentService.dart';
import 'package:flutterApp/models/comment.dart';
import 'package:flutterApp/services/locationService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutterApp/services/accountService.dart';
import 'package:flutterApp/helper/image.dart';
import 'package:flutterApp/theme/colors.dart';
import 'package:flutterApp/widgets/commentInput.dart';
import 'package:flutterApp/widgets/customDialog.dart';
import 'package:flutterApp/widgets/comment.dart';
import 'package:flutterApp/helper/image_utils.dart';

class PlaceDetailScreen extends StatefulWidget {
  final place_model.Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  List<Comment> comments = [];
  bool isLoading = true;
  int currentPage = 1;
  final int limit = 10;
  bool hasMore = true;
  String address = 'Loading address...';
  String sortBy = 'Newest'; // Bộ lọc hiện tại
  final AccountService _accountService = AccountService();
  final CommentService _commentService = CommentService();
  int _selectedRating = 0; // Default to 0 (no rating)
  List<String> _imagePaths = [];
  late TextEditingController
      _commentController; // Danh sách các đường dẫn hình ảnh

  // Thông tin người dùng
  String? name;
  String? email;
  String? phone;
  String? avatarUrl;
  String? token;
  final ImagePicker _picker = ImagePicker();
  bool _isCommenting = false;
  final String baseURL = 'http://10.0.2.2:8000/uploads/';

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    fetchComments();
    fetchAddress();
    _loadProfile();
  }

  // Callback để xóa bình luận
  Future<void> onDeleteComment(Comment comment) async {
    try {
      await _commentService.deleteComment(id: comment.id);
      setState(() {
        comments.removeWhere((item) => item.id == comment.id);
      });
      showErrorDialog(context, 'Comment deleted successfully');
    } catch (e) {
      print('Error deleting comment: $e');
      showErrorDialog(context, 'Failed to delete comment');
    }
  }

  @override
  void dispose() {
    _commentController.dispose(); // Hủy controller khi không dùng nữa
    super.dispose();
  }

  void showCustomDialog(BuildContext context, String title, String message,
      IconData typeIcon, Color color, VoidCallback onDialogClose) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: title,
            message: message,
            typeIcon: typeIcon,
            color: color,
            onDialogClose: onDialogClose,
          );
        });
  }

  void onCommentUpdated(Comment updatedComment) {
    setState(() {
      final index =
          comments.indexWhere((comment) => comment.id == updatedComment.id);
      if (index != -1) {
        comments[index] = updatedComment;
      }
    });
  }

  String formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _loadProfile() async {
    try {
      // Lấy thông tin profile từ API
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      if (token == null) {
        return; // Token không tồn tại
      }
      var response = await _accountService.getProfile();
      if (response['success']) {
        setState(() {
          name = response['data']['username'];
          email = response['data']['email'];
          phone = response['data']['phone'] ?? null;
        });
      } else {
        print('Error: ${response['message']}');
      }
    } catch (e) {
      print('Failed to load profile: $e');
    }
  }

  Future<void> fetchAddress() async {
    final fetchedAddress = await LocationService.fetchAddress(
      widget.place.latitude,
      widget.place.longitude,
    );
    setState(() {
      address = fetchedAddress;
    });
  }

  Future<void> fetchComments() async {
    if (!hasMore) return;
    setState(() => isLoading = true);
    try {
      final paginatedData = await _commentService.fetchCommentByPlace(
        id: widget.place.id,
        page: currentPage,
        limit: limit,
      );
      setState(() {
        comments.addAll(paginatedData.data);
        hasMore = paginatedData.totalPages > currentPage;
        currentPage++;
      });
    } catch (e) {
      print('Error fetching comments: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickAndProcessImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Validate ảnh bằng hàm utils
      final validationError = await validateImage(pickedFile);
      if (validationError != null) {
        // Hiển thị lỗi qua dialog
        showErrorDialog(context, validationError);
        return;
      }

      // Nếu hợp lệ, bắt đầu xử lý ảnh
      setState(() => isLoading = true);
      final convertedPath = await _convertAndSaveImage(pickedFile.path);
      if (convertedPath != null) {
        setState(() => _imagePaths.add(convertedPath));
      }
      setState(() => isLoading = false);
    }
  }

  Future<String?> _convertAndSaveImage(String originalPath) async {
    try {
      File originalFile = File(originalPath);
      File convertedFile = await convertImage(originalFile);
      return convertedFile.path;
    } catch (e) {
      print('Error converting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process image: $e')),
      );
      return null;
    }
  }

  void _toggleCommentInput() {
    setState(() {
      _isCommenting = !_isCommenting;
      if (!_isCommenting) {
        _selectedRating = 0;
        _commentController.clear();
        _imagePaths.clear();
      } else {
        if (name == null) {
          showCustomDialog(
              context,
              'Notify',
              'You must login to create comment',
              Icons.notifications,
              failureColor,
              () {});
          _isCommenting = !_isCommenting;
        }
      }
    });
  }

  Future<void> _onSubmit() async {
    if (_selectedRating == 0) {
      showErrorDialog(context, 'Please provide a rating');
      return;
    }
    setState(() {
      _isCommenting = false;
      isLoading = true;
    });
    try {
      final newComment = await _commentService.createComment(
        placeId: widget.place.id,
        star: _selectedRating,
        content: _commentController.text,
        imagePaths: _imagePaths,
      );
      setState(() {
        newComment.username = name;
        comments.insert(0, newComment);
        _selectedRating = 0;
        _commentController.clear();
        _imagePaths.clear();
      });
      showErrorDialog(context, 'Comment submitted successfully!');
    } catch (e) {
      showErrorDialog(context, 'Failed to create comment: $e');
      print('Error creating comment: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onRatingSelected(int rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  void _updateSort(String newSort) {
    setState(() {
      sortBy = newSort;
      comments.clear();
      currentPage = 1;
      hasMore = true;
    });
    fetchComments();
  }

  void _deleteImage(String imagePath) {
    setState(() {
      _imagePaths.remove(imagePath);
    });
    showErrorDialog(context, 'Image removed successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.directions, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.place.img,
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/images/placeholder.png',
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(widget.place.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Address: $address',
                  style: const TextStyle(
                      color: Color.fromARGB(255, 60, 60, 60), fontSize: 15)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('${widget.place.star}',
                      style: const TextStyle(fontSize: 18)),
                  const Icon(Icons.star, color: Colors.orange)
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${comments.length} comments', // Hiển thị số lượng comment
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildSortButton('Newest'),
                  _buildSortButton('Highest Rating'),
                  _buildSortButton('Lowest Rating'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              isLoading && comments.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : comments.isEmpty
                      ? const Text(
                          'No comments available.',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Column(
                          children: comments.map((comment) {
                            return CommentCard(
                              comment: comment,
                              baseURL: baseURL, // Truyền baseURL vào widget,
                              currentUsername: name,
                              onDeleteComment: onDeleteComment,
                              onUpdateComment: onCommentUpdated,
                            );
                          }).toList(),
                        ),
              if (isLoading && comments.isNotEmpty)
                const Center(child: CircularProgressIndicator()),
              if (!isLoading && hasMore)
                ElevatedButton(
                  onPressed: fetchComments,
                  child: const Text('Load More'),
                ),
              if (_isCommenting)
                CommentInput(
                  name: name,
                  isLoading: isLoading,
                  onDeleteImage: _deleteImage,
                  onRatingSelected: _onRatingSelected,
                  commentController: _commentController,
                  onSubmitComment: _onSubmit,
                  onUploadImage: _pickAndProcessImage,
                  selectedRating: _selectedRating,
                  imagePaths: _imagePaths,
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCommentInput, // Toggle comment input visibility
        child: Icon(
          _isCommenting ? Icons.close : Icons.add_comment,
        ),
      ),
    );
  }

  // Widget để tạo nút bộ lọc
  Widget _buildSortButton(String label) {
    return GestureDetector(
      onTap: () {
        _updateSort(label);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sortBy == label ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sortBy == label ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
