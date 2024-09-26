import 'package:flutter/material.dart';
import '../theme/colors.dart';

// Widget WeatherButton được sử dụng để hiển thị một nút nổi (FloatingActionButton) với biểu tượng thời tiết.
// Nút này có thể được đặt tại một vị trí cụ thể trên màn hình và thực hiện hành động khi được nhấn.
class WeatherButton extends StatelessWidget {
  // Callback được gọi khi người dùng nhấn vào nút.
  final VoidCallback onPressed;

  // Constructor của WeatherButton, nhận vào một callback onPressed.
  const WeatherButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Sử dụng widget Positioned để đặt FloatingActionButton tại một vị trí cố định trên màn hình.
    return Positioned(
      // Đặt nút cách 15% chiều cao của màn hình từ trên xuống.
      top: MediaQuery.of(context).size.height * 0.15,
      // Đặt nút cách 10 đơn vị từ mép trái của màn hình.
      left: 10.0,
      // Tạo FloatingActionButton có màu nền là primaryBlue (được định nghĩa trong file colors.dart).
      child: FloatingActionButton(
        backgroundColor: primaryBlue,
        // Gọi callback onPressed khi người dùng nhấn vào nút.
        onPressed: onPressed,
        // Biểu tượng thời tiết (hình đám mây) được hiển thị trên nút, với màu trắng.
        child: const Icon(Icons.cloud, color: Colors.white),
      ),
    );
  }
}
