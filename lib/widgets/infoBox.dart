import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/camera.dart';
import '../services/locationService.dart';

class CameraInfoBox extends StatefulWidget {
  final Camera camera;
  final YoutubePlayerController controller;
  final VoidCallback onPlay;

  const CameraInfoBox({
    super.key,
    required this.camera,
    required this.controller,
    required this.onPlay,
  });

  @override
  State<CameraInfoBox> createState() => _CameraInfoBoxState();
}

class _CameraInfoBoxState extends State<CameraInfoBox> {
  String _address = 'Loading address...';

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final fetchedAddress = await LocationService.fetchAddress(
      widget.camera.latitude,
      widget.camera.longitude,
    );
    setState(() {
      _address = fetchedAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: YoutubePlayer(
              controller: widget.controller,
              onReady: () {
                widget.controller.addListener(() {
                  if (widget.controller.value.isPlaying) {
                    widget.onPlay();
                  }
                });
              },
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.camera.status ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.camera.status ? 'LIVE' : 'OFFLINE',
                style: TextStyle(
                  color: widget.camera.status ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 220),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _address,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12, // 👈 Đưa về góc phải
          child: Builder(
            builder: (context) {
              final now = DateTime.now();
              final isDay =
                  now.hour >= 6 && now.hour < 18; // Từ 6h đến 18h là ban ngày

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDay ? Icons.wb_sunny : Icons.nightlight_round,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
