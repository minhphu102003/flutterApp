import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutterApp/services/reportService.dart';
import 'package:flutterApp/helper/image_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostScreen extends StatefulWidget {
  final double longitude;
  final double latitude;
  const CreatePostScreen(
      {super.key, required this.latitude, required this.longitude});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  String? _typeReport = 'Traffic Jam';
  final List<File> _images = []; 
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  Map<String, String> reportTypeMap = {
    'Traffic Jam': 'TRAFFIC_JAM',
    'Flood': 'FLOOD',
    'Accident': 'ACCIDENT',
    'RoadWork': 'ROADWORK',
  };
  ReportService _reportService = ReportService();

  Future<void> _sendReport() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      showErrorDialog(context, 'You must be logged in to submit a report.');
      return;
    }

    String reportTypeApiValue =
        reportTypeMap[_typeReport ?? 'Traffic Jam'] ?? 'TRAFFIC_JAM';
    String? description =
        _postController.text.isEmpty ? null : _postController.text;

    if (_images == null || _images.isEmpty) {
      showErrorDialog(
          context, 'You must upload at least one image to submit a report.');
      return; // Dừng lại nếu không có ảnh
    }

    setState(() {
      isLoading = true;
    });

    try {
      String result = await _reportService.createAccountReport(
        description: description ?? '',
        typeReport: reportTypeApiValue,
        longitude: widget.longitude,
        latitude: widget.latitude,
        imageFiles: _images,
      );

      _postController.clear(); 
      _typeReport = 'Traffic Jam'; 
      _images.clear(); 
      setState(() {}); 

      showErrorDialog(context, result);
    } catch (e) {
      showErrorDialog(context, 'Error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles =
        await _picker.pickMultiImage(); 
    if (pickedFiles != null) {
      setState(() {
        if (pickedFiles.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only select up to 5 photos.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        _images.addAll(pickedFiles.map((file) => File(file.path)));
        if (_images.length > 5) {
          _images.removeRange(5, _images.length); // Giới hạn tối đa 5 ảnh
        }
      });
    }
  }

  Future<void> _captureImage() async {
    final XFile? capturedFile =
        await _picker.pickImage(source: ImageSource.camera); // Sử dụng camera
    if (capturedFile != null) {
      setState(() {
        if (_images.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can only capture up to 5 photos.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          _images
              .add(File(capturedFile.path)); 
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        AssetImage(
                        'assets/images/defaultAvatar.png'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      decoration: InputDecoration(
                        hintText: 'Description of the images',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      // IconButton(
                      //   icon: const Icon(Icons.photo),
                      //   onPressed: _pickImages, // Gọi hàm chọn ảnh từ thư viện
                      // ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _captureImage, // Gọi hàm chụp ảnh từ camera
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            // Hiển thị hình ảnh đã chọn
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _images.isEmpty
                  ? Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: const Center(
                        child: Text('No pictures yet'),
                      ),
                    )
                  : SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: FileImage(_images[index]),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(
                                            index); // Xóa ảnh khỏi danh sách
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
            const Divider(),
            // Chọn trạng thái thời tiết
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('Type Report:'),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _typeReport,
                    onChanged: (String? newValue) {
                      setState(() {
                        _typeReport = newValue;
                      });
                    },
                    items: <String>[
                      'Traffic Jam',
                      'Flood',
                      'Accident',
                      'Road Work'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendReport,
                child: isLoading
                    ? const SizedBox(
                        height: 20, // Chiều cao của loading
                        width: 20,  // Chiều rộng của loading
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0, // Độ dày của đường tròn loading
                        ),
                      )
                    : const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
