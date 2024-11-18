import 'package:flutter/material.dart';

import '../widgets/customDialogWeather.dart'; // Đường dẫn này phải chính xác tới CustomDialogWeather của bạn.
import './weatherService.dart'; // Thay đổi thành đường dẫn thật của file service lấy thông tin thời tiết.
import '../helper/appConfig.dart';

class WeatherSuggestionService {
  final _weatherService = WeatherService(); // Thay đổi thành class quản lý gọi API của bạn.
  final String _dirImg = AppConfig.dirImg;

  void showWeatherSuggestion(double longitude, double latitude, BuildContext context) async {
    try {
      String dirImg = _dirImg;
      // Gọi API để lấy thông tin thời tiết
      Map<String, dynamic> response = await _weatherService.getSuggestion(longitude, latitude);
      if (response['success'] == true) {
        String message = response['data'];
        String weatherCode = response['code'];
        double temperature = response['temp'];

        List<String> img = [];
        if (weatherCode.isNotEmpty) {
          img.add('$dirImg/weather_${weatherCode[0]}.png');
          if (weatherCode.length > 1) {
            img.add('$dirImg/weather_second_${weatherCode[1]}.png');
          }
        }
        showDialog(
          context: context,
          builder: (context) => CustomDialogWeather(
            title: "Weather Suggestion",
            message: message,
            typeIcon: Icons.wb_sunny_outlined, // Có thể tùy chỉnh dựa trên mã thời tiết
            color: Colors.orange, // Cũng có thể tùy chỉnh
            imagePaths: img,
            temperature: temperature,
            onDialogClose: () {
              print("Dialog closed");
            },
          ),
        );
      } else {
        // Xử lý khi API trả về không thành công
        print("Failed to fetch weather suggestion: ${response['message']}");
      }
    } catch (e) {
      // Xử lý lỗi
      print("Error in fetching weather suggestion: $e");
    }
  }
}
