import 'package:flutter/material.dart';

class RouteInstructions extends StatelessWidget {
  final List<String> routeInstructions; // Danh sách hướng dẫn đường đi
  final String travelTime; // Thời gian di chuyển
  final double bottomPosition; // Vị trí tính từ dưới màn hình

  const RouteInstructions({
    super.key,
    required this.routeInstructions,
    required this.travelTime,
    this.bottomPosition = 50, // Giá trị mặc định
  });

  @override
  @override
Widget build(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.end, // Đặt ở cuối màn hình
    children: [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.8, // Chiều cao tối đa
        child: DraggableScrollableSheet(
          initialChildSize: 0.1,
          minChildSize: 0.1,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Detailed Directions ($travelTime)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...routeInstructions.map((instruction) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Text(
                          instruction,
                          style: const TextStyle(fontSize: 15),
                        ),
                      )),
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
