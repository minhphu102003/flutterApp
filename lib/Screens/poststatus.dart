import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Để xử lý File hình ảnh

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  String? _weatherStatus = 'Sunny'; // Trạng thái thời tiết mặc định
  File? _image; // Biến để lưu hình ảnh đã chọn

  final ImagePicker _picker = ImagePicker(); // Đối tượng ImagePicker

  // Hàm để chọn ảnh từ thư viện hoặc camera
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Chọn ảnh từ thư viện

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Lưu đường dẫn của ảnh đã chọn
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
                'https://via.placeholder.com/150'), // Placeholder avatar
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // Đóng trang create post
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần trên cùng: Người dùng đăng bài
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150'), // Avatar mẫu
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: InputDecoration(
                        hintText: 'Bạn đang nghĩ gì?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: _pickImage, // Gọi hàm chọn ảnh khi nhấn vào icon
                  ),
                ],
              ),
            ),
            const Divider(),
            // Thêm hình ảnh cho bài đăng
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _image == null
                  ? Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300], // Màu xám cho vùng chưa chọn ảnh
                      ),
                      child: const Center(
                        child: Text('Chưa có hình ảnh'),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
            ),
            const Divider(),
            // Chọn trạng thái thời tiết
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Weather status:'),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _weatherStatus,
                    onChanged: (String? newValue) {
                      setState(() {
                        _weatherStatus = newValue;
                      });
                    },
                    items: <String>['Sunny', 'Cloudy', 'Rainy', 'Windy']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Nút đăng bài
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Logic xử lý bài đăng, ví dụ: lưu vào cơ sở dữ liệu hoặc API
                  print('Post: ${_postController.text}');
                },
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
