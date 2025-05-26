import 'package:flutter/material.dart';
import 'package:flutterApp/constants/reportTypeMap.dart';
import 'package:flutterApp/models/mediaFile.dart';
import 'package:flutterApp/services/reportServiceV2.dart';
import 'package:flutterApp/widgets/actionButtonsReport.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutterApp/services/reportService.dart';
import 'package:flutterApp/helper/image_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterApp/widgets/typeReportDropdown.dart';

class CreatePostScreen extends StatefulWidget {
  final double longitude;
  final double latitude;
  const CreatePostScreen(
      {super.key, required this.latitude, required this.longitude});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _postController = TextEditingController();
  String? _typeReport = 'Traffic Jam';
  List<MediaFile> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool _isExpanded = false;
  final ReportService _reportService = ReportService();
  final ReportServiceV2 _reportServiceV2 = ReportServiceV2();
  late Animation<double> _rippleAnimation;
  late AnimationController _rippleController;
  late FocusNode _focusNode;

  bool get isUploadingImage =>
      _mediaFiles.any((media) => media.type == MediaType.image);

  bool get isUploadingVideo =>
      _mediaFiles.any((media) => media.type == MediaType.video);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    });
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _rippleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> _sendReport() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      showErrorDialog(context, 'You must be logged in to submit a report.');
      return;
    }

    if (_mediaFiles.isEmpty) {
      showErrorDialog(
          context, 'You must upload at least one image or a video.');
      return;
    }

    if (isUploadingImage && isUploadingVideo) {
      showErrorDialog(
          context, 'Cannot submit both images and video. Please choose one.');
      return;
    }

    String reportTypeApiValue =
        reportTypeMap[_typeReport ?? 'Traffic Jam'] ?? 'TRAFFIC_JAM';
    String? description =
        _postController.text.isEmpty ? null : _postController.text;

    setState(() {
      isLoading = true;
    });

    try {
      String result;

      if (isUploadingImage) {
        result = await _reportService.createAccountReport(
          description: description ?? '',
          typeReport: reportTypeApiValue,
          longitude: widget.longitude,
          latitude: widget.latitude,
          imageFiles: _mediaFiles.map((m) => m.file).toList(),
        );
      } else if (isUploadingVideo) {
        result = await _reportServiceV2.createVideoReport(
          description: description ?? '',
          typeReport: reportTypeApiValue,
          longitude: widget.longitude,
          latitude: widget.latitude,
          videoFile:
              _mediaFiles.first.file,
        );
      } else {
        throw Exception("No valid media file selected.");
      }

      _postController.clear();
      _typeReport = 'Traffic Jam';
      _mediaFiles.clear();
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

  Future<void> _captureImage() async {
    if (isUploadingVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You can only upload images or a single video, not both.')),
      );
      return;
    }

    final XFile? capturedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (capturedFile != null) {
      if (_mediaFiles.where((m) => m.type == MediaType.image).length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only add up to 5 images.')),
        );
        return;
      }

      final mediaFile = await MediaFile.create(
        file: File(capturedFile.path),
        type: MediaType.image,
      );

      setState(() {
        _mediaFiles.add(mediaFile);
      });
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    if (_mediaFiles.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('You can only upload a single video OR up to 5 images.')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedVideo = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 30),
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedVideo != null) {
      final mediaFile = await MediaFile.create(
        file: File(pickedVideo.path),
        type: MediaType.video,
      );

      setState(() {
        _mediaFiles.add(mediaFile);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundImage:
                                AssetImage('assets/images/defaultAvatar.png'),
                          ),
                          ActionButtons(
                            rippleAnimation: _rippleAnimation,
                            onCameraTap: _captureImage,
                            onVideoTap: () => _pickVideo(context),
                          ),
                        ],
                      )),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = true;
                      });
                    },
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: TextField(
                        controller: _postController,
                        focusNode: _focusNode,
                        maxLines: _isExpanded ? 4 : 1,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Description of the report',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.blueAccent, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _mediaFiles.isEmpty
                  ? Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: const Center(child: Text('No materials yet')),
                    )
                  : SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _mediaFiles.length,
                        itemBuilder: (context, index) {
                          final media = _mediaFiles[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: media.type == MediaType.image
                                      ? Image.file(media.file,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover)
                                      : Stack(
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              height: 150,
                                              child: Image.asset(
                                                'assets/images/video_placeholder.png', // hoặc thumbnail nếu extract
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const Positioned.fill(
                                              child: Center(
                                                child: Icon(
                                                    Icons.play_circle_fill,
                                                    size: 40,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _mediaFiles.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 20),
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
            TypeReportDropdown(
              value: _typeReport,
              onChanged: (String? newValue) {
                setState(() {
                  _typeReport = newValue;
                });
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendReport,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
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
