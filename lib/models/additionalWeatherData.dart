// Lớp để chứa dữ liệu thời tiết bổ sung, bao gồm lượng mưa, chỉ số UV và độ che phủ mây
class AdditionalWeatherData {
  final String precipitation; // Lượng mưa dưới dạng chuỗi
  final double uvi; // Chỉ số UV
  final int clouds; // Độ che phủ mây (tính bằng phần trăm)

  // Constructor yêu cầu các thông số đầu vào
  AdditionalWeatherData({
    required this.precipitation, 
    required this.uvi, 
    required this.clouds
  });

  // Phương thức factory để khởi tạo đối tượng từ dữ liệu JSON
  factory AdditionalWeatherData.fromJson(Map<String, dynamic> json) {
    // Lấy dữ liệu lượng mưa từ JSON và chuyển đổi thành chuỗi phần trăm
    final precipData = json['daily'][0]['pop'];
    final precip = (precipData * 100).toStringAsFixed(0); // Chuyển đổi sang chuỗi với 0 chữ số thập phân

    // Trả về đối tượng AdditionalWeatherData mới với dữ liệu từ JSON
    return AdditionalWeatherData(
      precipitation: precip, // Lượng mưa
      uvi: (json['daily'][0]['uvi']).toDouble(), // Chỉ số UV
      clouds: json['daily'][0]['clouds'] ?? 0 // Độ che phủ mây, mặc định là 0 nếu không có dữ liệu
    );
  }
}
