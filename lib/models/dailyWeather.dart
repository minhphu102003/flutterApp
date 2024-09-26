import 'package:flutter/material.dart';

// Lớp để chứa dữ liệu thời tiết hàng ngày, kế thừa từ ChangeNotifier để thông báo sự thay đổi cho người tiêu dùng
class Dailyweather with ChangeNotifier {
  final double temp; // Nhiệt độ hiện tại
  final double tempMin; // Nhiệt độ tối thiểu trong ngày
  final double tempMax; // Nhiệt độ tối đa trong ngày
  final double tempMorning; // Nhiệt độ vào buổi sáng
  final double tempDay; // Nhiệt độ vào buổi trưa
  final double tempEvening; // Nhiệt độ vào buổi chiều
  final double tempNight; // Nhiệt độ vào ban đêm
  final String weatherCategory; // Phân loại thời tiết (như Clear, Rain, etc.)
  final String condition; // Mô tả điều kiện thời tiết (như sunny, cloudy, etc.)
  final DateTime date; // Ngày của thông tin thời tiết
  final String precipitation; // Lượng mưa (dưới dạng chuỗi phần trăm)
  final double rainVolume; // Thể tích mưa (tính bằng mm)
  final int clouds; // Độ che phủ mây (tính bằng phần trăm)
  final int humidity; // Độ ẩm không khí (tính bằng phần trăm)

  // Constructor yêu cầu các thông số đầu vào
  Dailyweather({
    required this.temp, 
    required this.tempMin, 
    required this.tempMax, 
    required this.tempMorning, 
    required this.tempDay, 
    required this.tempEvening, 
    required this.tempNight, 
    required this.weatherCategory, 
    required this.condition, 
    required this.date, 
    required this.precipitation,
    required this.rainVolume,
    required this.clouds, 
    required this.humidity
  });

  // Phương thức tĩnh để khởi tạo đối tượng từ dữ liệu JSON
  static Dailyweather fromDailyJson(dynamic json) {
    return Dailyweather(
      // Chuyển đổi dữ liệu từ JSON sang các thuộc tính của lớp
      temp: (json['temp']['day']).toDouble(), // Nhiệt độ ban ngày
      tempMin: (json['temp']['min']).toDouble(), // Nhiệt độ tối thiểu
      tempMax: (json['temp']['max']).toDouble(), // Nhiệt độ tối đa
      tempMorning: (json['temp']['morn']).toDouble(), // Nhiệt độ buổi sáng
      tempDay: (json['temp']['day']).toDouble(), // Nhiệt độ ban ngày (lặp lại)
      tempEvening: (json['temp']['eve']).toDouble(), // Nhiệt độ buổi chiều
      tempNight: (json['temp']['night']).toDouble(), // Nhiệt độ ban đêm
      weatherCategory: json['weather'][0]['main'], // Phân loại thời tiết
      condition: json['weather'][0]['description'], // Mô tả thời tiết
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true), // Ngày
      precipitation: ((json['pop']).toDouble() * 100).toStringAsFixed(0), // Lượng mưa (%)
      rainVolume: json.containsKey('rain') ? (json['rain']).toDouble() : 0.0, // Thể tích mưa
      clouds: json['clouds'], // Độ che phủ mây
      humidity: json['humidity'], // Độ ẩm
    );
  }
}
