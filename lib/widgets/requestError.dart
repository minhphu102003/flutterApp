import 'package:flutter/material.dart';
import 'package:flutterApp/provider/weatherProvider.dart';
import 'package:provider/provider.dart';

// Widget hiển thị thông báo lỗi khi không tìm thấy kết quả
class RequestError extends StatelessWidget {
  const RequestError({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 150), // Thêm khoảng cách trên và dưới
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều dọc
        children: [
          const Icon(
            Icons.wrong_location_outlined,
            color: Colors.blue,
            size: 100, // Kích thước biểu tượng
          ),
          const SizedBox(height: 10), // Khoảng cách giữa biểu tượng và văn bản
          const Text(
            'No Search Result',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 30,
              fontWeight: FontWeight.w700, // Độ đậm của văn bản
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 75, vertical: 10),
            child: Text(
              "Please make sure that you entered the correct location or check your device internet connection",
              textAlign: TextAlign.center, // Căn giữa văn bản
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                fontWeight: FontWeight.w400, // Độ đậm của văn bản
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0), // Bo tròn góc của nút
              ),
            ),
            child: const Text('Return Home'), // Nội dung của nút
            onPressed: () => Provider.of<Weatherprovider>(context, listen: false)
                .getWeatherData(context, notify: true), // Hành động khi nhấn nút
          )
        ],
      ),
    );
  }
}
