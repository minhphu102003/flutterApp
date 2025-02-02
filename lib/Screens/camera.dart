import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  int? selectedBoxIndex;

  final List<String> videoUrls = [
    "https://www.youtube.com/watch?v=b6fkug3AmH4",
    "https://www.youtube.com/watch?v=cB9Fs9UmcRU",
    "https://www.youtube.com/watch?v=Fu3nDsqC1J0",
    "https://www.youtube.com/watch?v=IXBTD4VgFF4",
    "https://www.youtube.com/watch?v=F06HWCf22-Q",
  ];

  late List<YoutubePlayerController> _youtubeControllers;

  @override
  void initState() {
    super.initState();

    _youtubeControllers = videoUrls.map((url) {
      final videoId = YoutubePlayer.convertUrlToId(url) ?? '';
      return YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _youtubeControllers) {
      controller.dispose();
    }
    super.dispose();
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
        // Thanh tìm kiếm cố định
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white, // Giữ nền cố định
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              prefixIcon: const Icon(Icons.search),
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
        ),

        // Danh sách info box cuộn được
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBox(0, 'Vị trí: Công Trình bệnh viện Đà Nẵng', 'Quận: Hải Châu', 'Địa chỉ: ...'),
                const SizedBox(height: 16),
                _buildInfoBox(1, 'Vị trí: Trang Phục biểu diễn Phương Trần Đà Nẵng', 'Quận: Thanh Khê', 'Địa chỉ: 200 Lê Duẩn'),
                const SizedBox(height: 16),
                _buildInfoBox(2, 'Vị trí: Cổng trường Nguyễn Huệ Đà Nẵng', 'Quận: Sơn Trà', 'Địa chỉ: 50 Ngô Quyền'),
                const SizedBox(height: 16),
                _buildInfoBox(3, 'Vị trí: Cổng Sau bệnh viện C Đà Nẵng', 'Quận: Sơn Trà', 'Địa chỉ: 50 Ngô Quyền'),
                const SizedBox(height: 16),
                _buildInfoBox(4, 'Vị trí: Nút giao thông tây Cầu Rồng Đà Nẵng', 'Quận: Sơn Trà', 'Địa chỉ: 50 Ngô Quyền'),
              ],
            ),
          ),
        ),
      ],
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
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth, // Full width theo màn hình
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Đảm bảo con chiếm toàn bộ chiều rộng
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.shade100,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      district,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      address,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (selectedBoxIndex == index)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin chi tiết về vị trí: $position',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
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
      },
    ),
  );
}

}