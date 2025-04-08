import 'package:flutter/material.dart';

class RecentVideosSection extends StatelessWidget {
  const RecentVideosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Videos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(10, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        // Handle video tap here
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              // Thay URL bằng một ảnh test để kiểm tra
                              'https://kenh14cdn.com/thumb_w/660/2019/1/23/504161573570077317884627585794349414219776n-15482181400081330886703.jpg',
                              width: MediaQuery.of(context).size.width / 3 - 16,
                              height: 200,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: MediaQuery.of(context).size.width / 3 - 16,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: MediaQuery.of(context).size.width / 3 - 16,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, color: Colors.red, size: 40),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Icon(
                            Icons.play_circle_outline,
                            color: Color.fromARGB(255, 175, 174, 172),
                            size: 50,
                          ),
                          const Positioned(
                            top: 10,
                            left: 10,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  AssetImage('assets/images/defaultAvatar.png'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
