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
    temp: (json['main']['temp'] ?? 0).toDouble(),
    feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
    tempMin: (json['main']['temp_min'] ?? 0).toDouble(),
    tempMax: (json['main']['temp_max'] ?? 0).toDouble(),
    pressure: json['main']['pressure'] ?? 0,
    humidity: json['main']['humidity'] ?? 0,
    windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
    windGust: json['wind'] != null &&
              json['wind'].containsKey('gust') &&
              json['wind']['gust'] != null
        ? (json['wind']['gust']).toDouble()
        : 0.0,
    clouds: json['clouds'] != null ? json['clouds']['all'] ?? 0 : 0,
    weatherCategory: json['weather'] != null && json['weather'].isNotEmpty
        ? json['weather'][0]['main'] ?? ''
        : '',
    condition: json['weather'] != null && json['weather'].isNotEmpty
        ? json['weather'][0]['description'] ?? ''
        : '',
    date: json['dt_txt'] != null ? DateTime.parse(json['dt_txt']) : DateTime.now(),
    precipitation: json.containsKey('pop') && json['pop'] != null
        ? ((json['pop']).toDouble() * 100).toStringAsFixed(0)
        : "0",
    rainVolume: json.containsKey('rain') &&
                json['rain'] != null &&
                json['rain'].containsKey('1h') &&
                json['rain']['1h'] != null
        ? (json['rain']['1h']).toDouble()
        : 0.0,
    visibility: json['visibility'] ?? 0,
  );
}


}
