import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  int? selectedBoxIndex;

  // List of YouTube video URLs for each info box
  final List<String> videoUrls = [
    "https://www.youtube.com/watch?v=b6fkug3AmH4",
    "https://www.youtube.com/watch?v=cB9Fs9UmcRU",
    "https://www.youtube.com/watch?v=Fu3nDsqC1J0",
    "https://www.youtube.com/watch?v=IXBTD4VgFF4",
    "https://www.youtube.com/watch?v=F06HWCf22-Q",
  ];

  // List of controllers for each video
  late List<YoutubePlayerController> _youtubeControllers;

  @override
  void initState() {
    super.initState();

    // Initialize a YoutubePlayerController for each video URL
    _youtubeControllers = videoUrls.map((url) {
      final videoId = YoutubePlayer.convertUrlToId(url) ?? '';
      return YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    // Close each controller when the widget is disposed
    for (var controller in _youtubeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera DaNa Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                print("Tìm kiếm: $value");
              },
            ),
            SizedBox(height: 16),

            // Display each info box with its own YouTube player controller
            _buildInfoBox(
              0,
              'Vị trí: Công Trình bệnh viện Đà Nẵng',
              'Quận: Hải Châu',
              'Địa chỉ: ...',
            ),
            SizedBox(height: 16),
            _buildInfoBox(
              1,
              'Vị trí: Trang Phục biểu diễn Phương Trần Đà Nẵng',
              'Quận: Thanh Khê',
              'Địa chỉ: 200 Lê Duẩn',
            ),
            SizedBox(height: 16),
            _buildInfoBox(
              2,
              'Vị trí: Cổng trường Nguyễn Huệ Đà Nẵng',
              'Quận: Sơn Trà',
              'Địa chỉ: 50 Ngô Quyền',
            ),
            SizedBox(height: 16),
            _buildInfoBox(
              3,
              'Vị trí: Cổng Sau bệnh viện C Đà Nẵng',
              'Quận: Sơn Trà',
              'Địa chỉ: 50 Ngô Quyền',
            ),
            SizedBox(height: 16),
            _buildInfoBox(
              4,
              'Vị trí: Nút giao thông tây Cầu Rồng Đà Nẵng',
              'Quận: Sơn Trà',
              'Địa chỉ: 50 Ngô Quyền',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(int index, String position, String district, String address) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle selected box index
          selectedBoxIndex = selectedBoxIndex == index ? null : index;
        });
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.shade100,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  district,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  address,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          if (selectedBoxIndex == index)
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Thông tin chi tiết về vị trí: $position',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 10),
                  YoutubePlayer(
                    controller: _youtubeControllers[index],
                    showVideoProgressIndicator: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}