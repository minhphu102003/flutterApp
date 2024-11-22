import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterApp/models/place.dart' as place_model;
import 'package:flutterApp/services/commentService.dart';
import 'package:flutterApp/models/comment.dart';
import 'package:flutterApp/services/locationService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutterApp/services/accountService.dart';

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
  int _selectedRating = 0; // Default to 0 (no rating)

  // Thông tin người dùng
  String? name;
  String? email;
  String? phone;
  String? avatarUrl;
  String? token;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isCommenting = false;

  @override
  void initState() {
    super.initState();
    fetchComments();
    fetchAddress();
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

    setState(() {
      isLoading = true;
    });

    try {
      final paginatedData = await CommentService().fetchCommentByPlace(
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
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm để load profile của người dùng
  Future<void> _loadProfile() async {
    try {
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
          avatarUrl = response['data']['avatar'] ?? null; // Nếu có avatar
        });
      } else {
        print('Error: ${response['message']}');
      }
    } catch (e) {
      print('Failed to load profile: $e');
    }
  }
    // Hàm để cập nhật bộ lọc
  void _updateSort(String newSort) {
    setState(() {
      sortBy = newSort;
      comments.clear();  // Xóa các comment hiện tại để tải lại theo bộ lọc mới
      currentPage = 1;
      hasMore = true;
    });
    fetchComments();  // Gọi lại hàm lấy comment với bộ lọc mới
  }
    // Show or hide the comment input
  void _toggleCommentInput() {
    setState(() {
      if(_isCommenting) {
        setState(() {
        _selectedRating = 0;
      });
      }
      _isCommenting = !_isCommenting; 
    });
  }

// Comment input widget
Widget _buildCommentInput() {
  return GestureDetector(
    onTap: () {
      FocusScope.of(context).requestFocus(FocusNode());
    },
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị avatar nếu có, nếu không sẽ là avatar mặc định
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(name ?? 'Anonymous', style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          // Hiển thị 5 icon ngôi sao để người dùng đánh giá
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _selectedRating
                      ? Icons.star // Star is filled if selected
                      : Icons.star_border, // Star is empty if not selected
                  color: index < _selectedRating ? Colors.orange : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _selectedRating = index + 1; // Set the selected rating
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 10),
          // Mô tả bình luận
          TextField(
            decoration: const InputDecoration(
              hintText: 'Write your comment...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              // Lưu lại mô tả bình luận
            },
          ),
          const SizedBox(height: 10),
          // Upload ảnh
          ElevatedButton(
            onPressed: () async {
              final pickedFile = await _picker.pickImage(
                source: ImageSource.gallery,
              );
              if (pickedFile != null) {
                setState(() {
                  _image = pickedFile;
                });
              }
            },
            child: const Text('Upload Image'),
          ),
          if (_image != null)
            Image.file(
              File(_image!.path),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Submit comment logic
            },
            child: const Text('Submit Comment'),
          ),
        ],
      ),
    ),
  );
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
            onPressed: () {
              String googleMapsUrl =
                  'https://www.google.com/maps/search/?q=${widget.place.latitude},${widget.place.longitude}';
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
              onTap: () {
      FocusScope.of(context).requestFocus(FocusNode());
    },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.place.img,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
              const SizedBox(height: 10),
              Text(widget.place.name,
                  style:
                      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Address: $address',
                  style: const TextStyle(color: Color.fromARGB(255, 60, 60, 60), fontSize: 15)),
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
                '${comments.length} comments',  // Hiển thị số lượng comment
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
                      ? const Text('No comments available.',
                          style: TextStyle(color: Colors.grey))
                      : Column(
                          children: comments.map((comment) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(comment.username ?? 'Anonymous'),
                                subtitle: Text(comment.content),
                                trailing: Text('${comment.star} ⭐'),
                              ),
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
              if (_isCommenting) _buildCommentInput(),
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