import 'package:flutter/material.dart';

// Lớp để chứa dữ liệu thời tiết theo giờ, sử dụng ChangeNotifier để thông báo thay đổi
class HourlyWeather with ChangeNotifier {
  final double temp; // Nhiệt độ hiện tại
  final double feelsLike; // Nhiệt độ cảm nhận
  final double tempMin; // Nhiệt độ tối thiểu
  final double tempMax; // Nhiệt độ tối đa
  final int pressure; // Áp suất không khí
  final int humidity; // Độ ẩm
  final double windSpeed; // Tốc độ gió
  final double windGust; // Tốc độ gió giật
  final int clouds; // Tỷ lệ mây
  final String weatherCategory; // Thể loại thời tiết (ví dụ: Clear, Rain)
  final String condition; // Mô tả chi tiết thời tiết
  final DateTime date; // Thời gian dữ liệu thời tiết
  final String precipitation; // Tỉ lệ mưa
  final double rainVolume; // Khối lượng mưa trong 1 giờ
  final int visibility; // Tầm nhìn

  // Constructor yêu cầu các thông số đầu vào
  HourlyWeather({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windGust,
    required this.clouds,
    required this.weatherCategory,
    required this.condition,
    required this.date,
    required this.precipitation,
    required this.rainVolume,
    required this.visibility,
  });

  // Phương thức static để khởi tạo đối tượng từ dữ liệu JSON
  static HourlyWeather fromJson(dynamic json) {
    return HourlyWeather(
      temp: (json['main']['temp']).toDouble(), // Nhiệt độ
      feelsLike: (json['main']['feels_like']).toDouble(), // Nhiệt độ cảm nhận
      tempMin: (json['main']['temp_min']).toDouble(), // Nhiệt độ tối thiểu
      tempMax: (json['main']['temp_max']).toDouble(), // Nhiệt độ tối đa
      pressure: json['main']['pressure'], // Áp suất
      humidity: json['main']['humidity'], // Độ ẩm
      windSpeed: (json['wind']['speed']).toDouble(), // Tốc độ gió
      windGust: json['wind'].containsKey('gust') ? (json['wind']['gust']).toDouble() : 0.0, // Tốc độ gió giật, nếu có
      clouds: json['clouds']['all'], // Tỷ lệ mây
      weatherCategory: json['weather'][0]['main'], // Thể loại thời tiết
      condition: json['weather'][0]['description'], // Mô tả thời tiết
      date: DateTime.parse(json['dt_txt']), // Thời gian dữ liệu thời tiết
      precipitation: ((json['pop']).toDouble() * 100).toStringAsFixed(0), // Tỉ lệ mưa
      rainVolume: json.containsKey('rain') && json['rain'].containsKey('1h')
          ? (json['rain']['1h']).toDouble() // Khối lượng mưa trong 1 giờ
          : 0.0,
      visibility: json['visibility'], // Tầm nhìn
    );
  }
}
