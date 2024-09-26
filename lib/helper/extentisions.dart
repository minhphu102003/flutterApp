// Mở rộng lớp String để thêm các phương thức tiện ích cho chuỗi
extension StringCasingExtension on String {
  // Chuyển đổi chuỗi thành dạng chữ hoa chữ cái đầu tiên và chữ thường cho phần còn lại
  String toCapitalized() =>
    length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  // Chuyển đổi chuỗi thành dạng tiêu đề (chữ cái đầu tiên của mỗi từ viết hoa)
  String toTitleCase() => 
    replaceAll(RegExp(' +'), ' ') // Thay thế các khoảng trắng liên tiếp bằng một khoảng trắng
    .split(' ') // Tách chuỗi thành danh sách các từ
    .map((str) => str.toCapitalized()) // Áp dụng phương thức toCapitalized cho từng từ
    .join(' '); // Kết hợp các từ lại thành một chuỗi
}

// Mở rộng lớp double để thêm các phương thức tiện ích cho số thực
extension DoubleExtension on double {
  // Chuyển đổi giá trị độ C sang độ F
  double toFahrenheit() => (this * 1.8 + 32).toDouble(); // Công thức chuyển đổi
}
