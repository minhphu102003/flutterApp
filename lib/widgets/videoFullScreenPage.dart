import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoFullScreenPage extends StatefulWidget {
  final String videoUrl;

  const VideoFullScreenPage({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  State<VideoFullScreenPage> createState() => _VideoFullScreenPageState();
}

class _VideoFullScreenPageState extends State<VideoFullScreenPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    debugPrint("Video full screen opened");
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    await _videoPlayerController.initialize();

    _videoPlayerController.addListener(() {
      final bool isEnded = _videoPlayerController.value.position >=
          _videoPlayerController.value.duration;

      if (isEnded && mounted) {
        Navigator.pop(context);
      }
    });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: false,
      showControls: false,
      overlay: const SizedBox(),
    );

    setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized
          ? Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
