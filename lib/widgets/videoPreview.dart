import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final String videoUrl;

  const VideoPreview({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    print('Video URL: ${widget.videoUrl}');
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    try {
      print("Initializing video controller...");
      final videoUri = Uri.parse(widget.videoUrl);
      final videoPlayerController =
          VideoPlayerController.network(videoUri.toString());

      // Đợi video tải xong trước khi khởi tạo ChewieController
      await videoPlayerController.initialize();

      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
        );
        _isInitialized = true;
      });

      videoPlayerController.setVolume(0);
      videoPlayerController.play();
      print('Video Initialized');
    } catch (error) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        print("Error initializing video: $error");
      }
    }
  }

  @override
  void dispose() {
    if (_chewieController != null) {
      _chewieController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return _isInitialized ? _buildVideoPlayer() : _buildLoadingWidget();
  }

  Widget _buildErrorWidget() {
    return Container(
      width: MediaQuery.of(context).size.width / 3 - 16,
      height: 200,
      color: Colors.grey[300],
      child: const Center(child: Text("Failed to load video")),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3 - 16,
        height: 200,
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _chewieController!.videoPlayerController.value.size.width,
            height: _chewieController!.videoPlayerController.value.size.height,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: MediaQuery.of(context).size.width / 3 - 16,
      height: 200,
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
