import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Widget CustomShimmer được sử dụng để tạo hiệu ứng nhấp nháy (shimmer effect) cho một vùng nhất định trên giao diện.
// Hiệu ứng này thường được sử dụng để hiển thị trạng thái loading, mô phỏng dữ liệu chưa được tải xong.
class CustomShimmer extends StatelessWidget {
  // Chiều cao của vùng nhấp nháy
  final double height;
  // Chiều rộng của vùng nhấp nháy
  final double width;
  // Độ bo góc của vùng nhấp nháy, có thể truyền vào hoặc để null.
  final BorderRadius? borderRadius;

  // Constructor của CustomShimmer, nhận vào các tham số về kích thước và độ bo góc.
  const CustomShimmer({
    super.key,
    this.height = 32.0,
    this.width = 32.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Sử dụng widget Shimmer.fromColors để tạo hiệu ứng nhấp nháy.
    return Shimmer.fromColors(
      // Màu sắc cơ bản của hiệu ứng nhấp nháy.
      baseColor: Colors.grey.shade300,
      // Màu sắc sáng hơn để tạo hiệu ứng di chuyển.
      highlightColor: Colors.grey.shade100,
      // Widget con sẽ được áp dụng hiệu ứng nhấp nháy.
      child: Container(
        // Cấu hình khung và màu sắc của vùng nhấp nháy.
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius, // Bo góc nếu có
        ),
        // Kích thước của vùng nhấp nháy.
        height: height,
        width: width,
      ),
    );
  }
}
