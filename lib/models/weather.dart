import 'package:flutter/cupertino.dart';

// Lớp Weather chứa dữ liệu thời tiết hiện tại và thông tin liên quan
class Weather with ChangeNotifier {
  final double temp; // Nhiệt độ hiện tại
  final double tempMax; // Nhiệt độ tối đa
  final double tempMin; // Nhiệt độ tối thiểu
  final double lat; // Vĩ độ
  final double long; // Kinh độ
  final double feelsLike; // Nhiệt độ cảm nhận
  final int pressure; // Áp suất không khí
  final String description; // Mô tả thời tiết
  final String weatherCategory; // Thể loại thời tiết (ví dụ: Clear, Rain)
  final int humidity; // Độ ẩm
  final double windSpeed; // Tốc độ gió
  String city; // Tên thành phố
  final String countryCode; // Mã quốc gia

  // Constructor yêu cầu các thông số đầu vào
  Weather({
    required this.temp,
    required this.tempMax,
    required this.tempMin,
    required this.lat,
    required this.long,
    required this.feelsLike,
    required this.pressure,
    required this.description,
    required this.weatherCategory,
    required this.humidity,
    required this.windSpeed,
    required this.city,
    required this.countryCode
  });

  // Factory method để khởi tạo đối tượng Weather từ dữ liệu JSON
  factory Weather.fromJson(Map<String,dynamic> json) {
    return Weather(
      temp: (json['main']['temp']).toDouble(), // Nhiệt độ
      tempMax: (json['main']['temp_max']).toDouble(), // Nhiệt độ tối đa
      tempMin: (json['main']['temp_min']).toDouble(), // Nhiệt độ tối thiểu
      lat: json['coord']['lat'], // Vĩ độ
      long: json['coord']['lon'], // Kinh độ
      feelsLike: (json['main']['feels_like']).toDouble(), // Nhiệt độ cảm nhận
      pressure: json['main']['pressure'], // Áp suất
      description: json['weather'][0]['description'], // Mô tả thời tiết
      weatherCategory: json['weather'][0]['main'], // Thể loại thời tiết
      humidity: json['main']['humidity'], // Độ ẩm
      windSpeed: (json['wind']['speed']).toDouble(), // Tốc độ gió
      city: json['name'], // Tên thành phố
      countryCode: json['sys']['country'] // Mã quốc gia
    );
  }
}
