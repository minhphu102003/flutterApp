import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../widgets/infoBox.dart';
import 'package:flutterApp/services/cameraService.dart';
import 'package:flutterApp/models/camera.dart';
import '../widgets/searchBarCamera.dart';
import '../widgets/addressSelector.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraState();
}

class _CameraState extends State<CameraScreen> {
  int? selectedBoxIndex;

  final CameraService _cameraService = CameraService();
  List<Camera> _cameras = [];
  bool _isLoading = true;
  String selectedCity = 'Da Nang';
  final List<YoutubePlayerController> _controllers = [];
  int? _playingIndex;

  final List<String> cities = ['Da Nang', 'Ho Chi Minh', 'Ha Noi'];

  Future<void> _fetchCameraData() async {
    try {
      final data = await _cameraService.fetchNearbyCameras(
        latitude: 16.9078564,
        longitude: 108.3424125,
      );

      setState(() {
        _cameras = data.data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cameras: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCameraData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Camera DaNa Hub'),
      ),
      body: Column(
        children: [
          SearchBarCamera(
            onChanged: (value) {
              print("Tìm kiếm: $value");
            },
          ),
          AddressSelector(
            selectedCity: selectedCity,
            cities: cities,
            onCityChanged: (value) {
              setState(() {
                selectedCity = value;
              });
              print("Đã chọn thành phố: $value");
            },
          ),
          Expanded(
            child: Container(
              color: const Color.fromARGB(221, 86, 86, 86),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(_cameras.length, (index) {
                          final camera = _cameras[index];

                          final controller = YoutubePlayerController(
                            initialVideoId:
                                YoutubePlayer.convertUrlToId(camera.link) ?? '',
                            flags: const YoutubePlayerFlags(autoPlay: false),
                          );
                          _controllers.add(controller);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: CameraInfoBox(
                              camera: camera,
                              controller: controller,
                              onPlay: () {
                                for (int i = 0; i < _controllers.length; i++) {
                                  if (i != index) {
                                    _controllers[i].pause();
                                  }
                                }
                                setState(() {
                                  _playingIndex = index;
                                });
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
