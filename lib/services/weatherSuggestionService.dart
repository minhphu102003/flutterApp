import 'package:flutter/material.dart';

import '../widgets/customDialogWeather.dart';
import './weatherService.dart'; 
import '../helper/appConfig.dart';

class WeatherSuggestionService {
  final _weatherService =
      WeatherService(); 
  final String _dirImg = AppConfig.dirImg;

  void showWeatherSuggestion(
      double longitude, double latitude, BuildContext context) async {
    try {
      String dirImg = _dirImg;
      Map<String, dynamic> response =
          await _weatherService.getSuggestion(longitude, latitude);
      if (response['success'] == true) {
        String message = response['data'];
        String weatherCode = response['code'];
        double temperature = response['temp'];

        List<String> img = [];
        if (weatherCode.length == 1) {
          img.add('$dirImg/weather.png');
        }
        if (weatherCode.length == 2) {
          img.add('$dirImg/weather_second_${weatherCode[1]}.png');
        }
        showDialog(
          context: context,
          builder: (context) => CustomDialogWeather(
            title: "Weather Suggestion",
            message: message,
            typeIcon: Icons
                .wb_sunny_outlined,
            color: Colors.orange, 
            imagePaths: img,
            temperature: temperature,
            onDialogClose: () {},
          ),
        );
      } else {}
    // ignore: empty_catches
    } catch (e) {}
  }
}
